//// Exact-time conversion and rounding for fixed-offset zoned date-times.

import bigi
import gleam/int
import gleam/order
import temporal
import temporal/calendar
import temporal/duration
import temporal/plain_date_time

const nanoseconds_per_day = 86_400_000_000_000

const nanoseconds_per_hour = 3_600_000_000_000

const nanoseconds_per_minute = 60_000_000_000

const nanoseconds_per_second = 1_000_000_000

const nanoseconds_per_millisecond = 1_000_000

const nanoseconds_per_microsecond = 1000

/// Convert exact epoch nanoseconds to a local ISO date-time.
pub fn to_plain_date_time(
  epoch_nanoseconds: bigi.BigInt,
  offset_nanoseconds: Int,
  calendar_value: calendar.Calendar,
) -> Result(plain_date_time.PlainDateTime, temporal.Error) {
  let local = bigi.add(epoch_nanoseconds, bigi.from_int(offset_nanoseconds))
  let day_size = bigi.from_int(nanoseconds_per_day)
  let truncated_days = bigi.divide(local, day_size)
  let truncated_remainder =
    bigi.subtract(local, bigi.multiply(truncated_days, day_size))
  let is_negative_remainder =
    bigi.compare(truncated_remainder, bigi.from_int(0)) == order.Lt
  let days = case bigi.to_int(truncated_days) {
    Ok(value) if is_negative_remainder -> value - 1
    Ok(value) -> value
    Error(_) -> 0
  }
  let within_day = case is_negative_remainder {
    True -> bigi.add(truncated_remainder, day_size)
    False -> truncated_remainder
  }
  use time_nanoseconds <- result_try(case bigi.to_int(within_day) {
    Ok(value) -> Ok(value)
    Error(_) ->
      Error(temporal.OutOfRange(
        temporal.EpochNanoseconds,
        bigi.to_string(epoch_nanoseconds),
      ))
  })
  let #(year, month, day) = civil_from_days(days)
  let hour = time_nanoseconds / nanoseconds_per_hour
  let after_hour = modulo(time_nanoseconds, nanoseconds_per_hour)
  let minute = after_hour / nanoseconds_per_minute
  let after_minute = modulo(after_hour, nanoseconds_per_minute)
  let second = after_minute / nanoseconds_per_second
  let after_second = modulo(after_minute, nanoseconds_per_second)
  let millisecond = after_second / nanoseconds_per_millisecond
  let after_millisecond = modulo(after_second, nanoseconds_per_millisecond)
  let microsecond = after_millisecond / nanoseconds_per_microsecond
  let nanosecond = modulo(after_millisecond, nanoseconds_per_microsecond)
  plain_date_time.new(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: second,
    millisecond: millisecond,
    microsecond: microsecond,
    nanosecond: nanosecond,
    calendar: calendar_value,
    overflow: temporal.Reject,
  )
}

/// Round exact epoch nanoseconds to a fixed unit increment.
pub fn round_epoch(
  epoch_nanoseconds: bigi.BigInt,
  unit: duration.Unit,
  increment: Int,
  mode: temporal.RoundingMode,
) -> Result(bigi.BigInt, temporal.Error) {
  case unit_nanoseconds(unit), valid_rounding_increment(unit, increment) {
    Ok(unit_size), True ->
      Ok(round_bigint(
        epoch_nanoseconds,
        bigi.from_int(unit_size * increment),
        mode,
      ))
    _, _ -> Error(temporal.InvalidOption(temporal.RoundingIncrementOption))
  }
}

/// Return an exact difference balanced from the requested largest fixed unit.
pub fn difference(
  first: bigi.BigInt,
  second: bigi.BigInt,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  let duration.DifferenceOptions(
    largest_unit:,
    smallest_unit:,
    rounding_increment:,
    rounding_mode:,
  ) = options
  case
    fixed_unit(largest_unit),
    fixed_unit(smallest_unit),
    unit_rank(largest_unit) <= unit_rank(smallest_unit),
    valid_difference_increment(smallest_unit, rounding_increment)
  {
    True, True, True, True -> {
      use unit_size <- result_try(unit_nanoseconds(smallest_unit))
      let rounded =
        round_bigint(
          bigi.subtract(second, first),
          bigi.from_int(unit_size * rounding_increment),
          rounding_mode,
        )
      from_nanoseconds(rounded, largest_unit)
    }
    _, _, _, _ -> Error(temporal.InvalidOption(temporal.DifferenceOptions))
  }
}

fn from_nanoseconds(
  total: bigi.BigInt,
  largest_unit: duration.Unit,
) -> Result(duration.Duration, temporal.Error) {
  let negative = bigi.compare(total, bigi.from_int(0)) == order.Lt
  let magnitude = case negative {
    True -> bigi.multiply(total, bigi.from_int(-1))
    False -> total
  }
  let #(weeks, after_weeks) = take_unit(magnitude, largest_unit, duration.Week)
  let #(days, after_days) = take_unit(after_weeks, largest_unit, duration.Day)
  let #(hours, after_hours) = take_unit(after_days, largest_unit, duration.Hour)
  let #(minutes, after_minutes) =
    take_unit(after_hours, largest_unit, duration.Minute)
  let #(seconds, after_seconds) =
    take_unit(after_minutes, largest_unit, duration.Second)
  let #(milliseconds, after_milliseconds) =
    take_unit(after_seconds, largest_unit, duration.Millisecond)
  let #(microseconds, after_microseconds) =
    take_unit(after_milliseconds, largest_unit, duration.Microsecond)
  use nanoseconds <- result_try(to_int(after_microseconds))
  Ok(duration.Duration(
    is_negative: negative
      && bigi.compare(magnitude, bigi.from_int(0)) != order.Eq,
    years: 0,
    months: 0,
    weeks: weeks,
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
    microseconds: microseconds,
    nanoseconds: nanoseconds,
  ))
}

fn take_unit(
  value: bigi.BigInt,
  largest: duration.Unit,
  unit: duration.Unit,
) -> #(Int, bigi.BigInt) {
  case unit_rank(largest) <= unit_rank(unit) {
    False -> #(0, value)
    True -> {
      let size = fixed_unit_nanoseconds(unit)
      let divisor = bigi.from_int(size)
      let quotient = bigi.divide(value, divisor)
      let remainder = bigi.subtract(value, bigi.multiply(quotient, divisor))
      let count = case bigi.to_int(quotient) {
        Ok(value) -> value
        Error(_) -> 0
      }
      #(count, remainder)
    }
  }
}

fn fixed_unit_nanoseconds(unit: duration.Unit) -> Int {
  case unit {
    duration.Year | duration.Month -> 1
    duration.Week -> 604_800_000_000_000
    duration.Day -> nanoseconds_per_day
    duration.Hour -> nanoseconds_per_hour
    duration.Minute -> nanoseconds_per_minute
    duration.Second -> nanoseconds_per_second
    duration.Millisecond -> nanoseconds_per_millisecond
    duration.Microsecond -> nanoseconds_per_microsecond
    duration.Nanosecond -> 1
  }
}

fn round_bigint(
  value: bigi.BigInt,
  increment: bigi.BigInt,
  mode: temporal.RoundingMode,
) -> bigi.BigInt {
  let zero = bigi.from_int(0)
  let negative = bigi.compare(value, zero) == order.Lt
  let magnitude = case negative {
    True -> bigi.multiply(value, bigi.from_int(-1))
    False -> value
  }
  let quotient = bigi.divide(magnitude, increment)
  let remainder = bigi.subtract(magnitude, bigi.multiply(quotient, increment))
  let twice_remainder = bigi.multiply(remainder, bigi.from_int(2))
  let comparison = bigi.compare(twice_remainder, increment)
  let odd = case
    bigi.to_int(bigi.subtract(
      quotient,
      bigi.multiply(bigi.divide(quotient, bigi.from_int(2)), bigi.from_int(2)),
    ))
  {
    Ok(1) -> True
    _ -> False
  }
  let has_remainder = bigi.compare(remainder, zero) != order.Eq
  let increase = case has_remainder {
    False -> False
    True ->
      case mode {
        temporal.Trunc -> False
        temporal.Expand -> True
        temporal.Ceil -> !negative
        temporal.Floor -> negative
        temporal.HalfExpand -> comparison != order.Lt
        temporal.HalfTrunc -> comparison == order.Gt
        temporal.HalfCeil ->
          comparison == order.Gt || comparison == order.Eq && !negative
        temporal.HalfFloor ->
          comparison == order.Gt || comparison == order.Eq && negative
        temporal.HalfEven ->
          comparison == order.Gt || comparison == order.Eq && odd
      }
  }
  let rounded_quotient = case increase {
    True -> bigi.add(quotient, bigi.from_int(1))
    False -> quotient
  }
  let rounded = bigi.multiply(rounded_quotient, increment)
  case negative {
    True -> bigi.multiply(rounded, bigi.from_int(-1))
    False -> rounded
  }
}

fn fixed_unit(unit: duration.Unit) -> Bool {
  case unit {
    duration.Year | duration.Month -> False
    _ -> True
  }
}

fn valid_rounding_increment(unit: duration.Unit, increment: Int) -> Bool {
  let dividend = case unit {
    duration.Day -> 1
    duration.Hour -> 24
    duration.Minute | duration.Second -> 60
    duration.Millisecond | duration.Microsecond | duration.Nanosecond -> 1000
    duration.Year | duration.Month | duration.Week -> 0
  }
  increment > 0
  && increment <= dividend
  && case int.modulo(dividend, increment) {
    Ok(0) -> True
    _ -> False
  }
}

fn valid_difference_increment(unit: duration.Unit, increment: Int) -> Bool {
  case unit {
    duration.Week -> increment > 0
    _ -> valid_rounding_increment(unit, increment)
  }
}

fn unit_nanoseconds(unit: duration.Unit) -> Result(Int, temporal.Error) {
  case unit {
    duration.Year | duration.Month ->
      Error(temporal.InvalidOption(temporal.DifferenceOptions))
    duration.Week -> Ok(604_800_000_000_000)
    duration.Day -> Ok(nanoseconds_per_day)
    duration.Hour -> Ok(nanoseconds_per_hour)
    duration.Minute -> Ok(nanoseconds_per_minute)
    duration.Second -> Ok(nanoseconds_per_second)
    duration.Millisecond -> Ok(nanoseconds_per_millisecond)
    duration.Microsecond -> Ok(nanoseconds_per_microsecond)
    duration.Nanosecond -> Ok(1)
  }
}

fn unit_rank(unit: duration.Unit) -> Int {
  case unit {
    duration.Year -> 0
    duration.Month -> 1
    duration.Week -> 2
    duration.Day -> 3
    duration.Hour -> 4
    duration.Minute -> 5
    duration.Second -> 6
    duration.Millisecond -> 7
    duration.Microsecond -> 8
    duration.Nanosecond -> 9
  }
}

// Howard Hinnant's proleptic-Gregorian civil date algorithm.
fn civil_from_days(days: Int) -> #(Int, Int, Int) {
  let shifted = days + 719_468
  let era = floor_div(shifted, 146_097)
  let day_of_era = shifted - era * 146_097
  let year_of_era =
    floor_div(
      day_of_era
        - floor_div(day_of_era, 1460)
        + floor_div(day_of_era, 36_524)
        - floor_div(day_of_era, 146_096),
      365,
    )
  let initial_year = year_of_era + era * 400
  let day_of_year =
    day_of_era
    - {
      365
      * year_of_era
      + floor_div(year_of_era, 4)
      - floor_div(year_of_era, 100)
    }
  let month_prime = floor_div(5 * day_of_year + 2, 153)
  let day = day_of_year - floor_div(153 * month_prime + 2, 5) + 1
  let month = case month_prime < 10 {
    True -> month_prime + 3
    False -> month_prime - 9
  }
  let year = case month <= 2 {
    True -> initial_year + 1
    False -> initial_year
  }
  #(year, month, day)
}

fn floor_div(value: Int, divisor: Int) -> Int {
  let quotient = value / divisor
  case value < 0 && modulo(value, divisor) != 0 {
    True -> quotient - 1
    False -> quotient
  }
}

fn modulo(value: Int, divisor: Int) -> Int {
  case int.modulo(value, divisor) {
    Ok(remainder) -> remainder
    Error(_) -> 0
  }
}

fn to_int(value: bigi.BigInt) -> Result(Int, temporal.Error) {
  case bigi.to_int(value) {
    Ok(value) -> Ok(value)
    Error(_) ->
      Error(temporal.OutOfRange(
        temporal.EpochNanoseconds,
        bigi.to_string(value),
      ))
  }
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
