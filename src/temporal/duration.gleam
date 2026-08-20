//// ISO 8601 durations and Temporal duration arithmetic.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq}
import gleam/result
import gleam/string
import temporal
import temporal/internal/duration_parser

const nanoseconds_per_microsecond = 1000

const nanoseconds_per_millisecond = 1_000_000

const nanoseconds_per_second = 1_000_000_000

const nanoseconds_per_minute = 60_000_000_000

const nanoseconds_per_hour = 3_600_000_000_000

const nanoseconds_per_day = 86_400_000_000_000

const nanoseconds_per_week = 604_800_000_000_000

const maximum_calendar_field = 4_294_967_295

const maximum_seconds = 9_007_199_254_740_991

/// A signed duration whose integer fields are non-negative magnitudes.
pub type Duration {
  Duration(
    is_negative: Bool,
    years: Int,
    months: Int,
    weeks: Int,
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    milliseconds: Int,
    microseconds: Int,
    nanoseconds: Int,
  )
}

/// An ISO date or date-time that supplies calendar context.
pub opaque type RelativeTo {
  RelativeTo(iso_8601: String, year: Int, month: Int, day: Int)
}

/// A Temporal date or time unit.
pub type Unit {
  Year
  Month
  Week
  Day
  Hour
  Minute
  Second
  Millisecond
  Microsecond
  Nanosecond
}

/// Whether a serializable annotation is shown.
pub type Display {
  Auto
  Always
  Never
  Critical
}

/// Fractional-second precision for serialization.
pub type Precision {
  AutoPrecision
  Digits(Int)
}

/// Typed options for difference operations.
pub type DifferenceOptions {
  DifferenceOptions(
    largest_unit: Unit,
    smallest_unit: Unit,
    rounding_increment: Int,
    rounding_mode: temporal.RoundingMode,
  )
}

/// Typed options for ISO serialization.
pub type ToStringOptions {
  ToStringOptions(
    precision: Precision,
    smallest_unit: Option(Unit),
    rounding_mode: temporal.RoundingMode,
    calendar_name: Display,
    time_zone_name: Display,
    offset: Display,
  )
}

/// Parses a Temporal ISO 8601 duration.
///
/// Fractions are accepted only on the smallest supplied time unit and may
/// contain at most nine decimal digits.
pub fn from_iso_8601(value: String) -> Result(Duration, temporal.Error) {
  case duration_parser.parse(value) {
    Error(Nil) -> Error(temporal.InvalidIsoString(input: value))
    Ok(parsed) -> {
      let duration_parser.ParsedDuration(
        is_negative:,
        years:,
        months:,
        weeks:,
        days:,
        hours:,
        minutes:,
        seconds:,
        fractional_nanoseconds:,
      ) = parsed
      let fractional_minutes = fractional_nanoseconds / nanoseconds_per_minute
      let after_minutes = fractional_nanoseconds % nanoseconds_per_minute
      let fractional_seconds = after_minutes / nanoseconds_per_second
      let after_seconds = after_minutes % nanoseconds_per_second
      let duration =
        Duration(
          is_negative: is_negative,
          years: years,
          months: months,
          weeks: weeks,
          days: days,
          hours: hours,
          minutes: minutes + fractional_minutes,
          seconds: seconds + fractional_seconds,
          milliseconds: after_seconds / nanoseconds_per_millisecond,
          microseconds: after_seconds
            % nanoseconds_per_millisecond
            / nanoseconds_per_microsecond,
          nanoseconds: after_seconds % nanoseconds_per_microsecond,
        )
        |> canonicalize_zero
      validate(duration)
    }
  }
}

/// Serializes a duration using Temporal's canonical ISO 8601 form.
pub fn to_iso_8601(duration: Duration) -> String {
  serialize(duration, AutoPrecision)
}

/// Parses an ISO date or date-time for relative duration operations.
pub fn relative_to_from_iso_8601(
  value: String,
) -> Result(RelativeTo, temporal.Error) {
  case parse_relative_date(value) {
    Ok(#(year, month, day)) ->
      case valid_iso_date(year, month, day) {
        True -> Ok(RelativeTo(value, year, month, day))
        False -> Error(temporal.InvalidIsoString(input: value))
      }
    Error(Nil) -> Error(temporal.InvalidIsoString(input: value))
  }
}

/// Validates field signs and Temporal's duration limits.
pub fn validate(duration: Duration) -> Result(Duration, temporal.Error) {
  let fields = [
    duration.years,
    duration.months,
    duration.weeks,
    duration.days,
    duration.hours,
    duration.minutes,
    duration.seconds,
    duration.milliseconds,
    duration.microseconds,
    duration.nanoseconds,
  ]
  case list.any(fields, fn(field) { field < 0 }) {
    True ->
      Error(temporal.InvalidDuration(
        reason: "duration fields must be non-negative",
      ))
    False ->
      case
        duration.years > maximum_calendar_field
        || duration.months > maximum_calendar_field
        || duration.weeks > maximum_calendar_field
      {
        True ->
          Error(temporal.InvalidDuration(
            reason: "calendar duration field exceeds the Temporal limit",
          ))
        False -> validate_time_range(duration)
      }
  }
}

fn validate_time_range(duration: Duration) -> Result(Duration, temporal.Error) {
  let whole_seconds =
    duration.days
    * 86_400
    + duration.hours
    * 3600
    + duration.minutes
    * 60
    + duration.seconds
  case whole_seconds > maximum_seconds {
    True ->
      Error(temporal.InvalidDuration(
        reason: "duration time portion exceeds the Temporal limit",
      ))
    False -> Ok(canonicalize_zero(duration))
  }
}

/// Compares two durations using optional ISO calendar context.
pub fn compare(
  first: Duration,
  second: Duration,
  relative_to: Option(RelativeTo),
) -> Result(Order, temporal.Error) {
  use first <- result.try(validate(first))
  use second <- result.try(validate(second))
  case equal(first, second) {
    True -> Ok(Eq)
    False -> {
      use first_total <- result.try(comparable_nanoseconds(first, relative_to))
      use second_total <- result.try(comparable_nanoseconds(second, relative_to))
      Ok(int.compare(first_total, second_total))
    }
  }
}

/// Reports whether two canonical duration records have identical fields.
pub fn equal(first: Duration, second: Duration) -> Bool {
  canonicalize_zero(first) == canonicalize_zero(second)
}

/// Adds two durations and balances their time fields.
///
/// Opposing calendar durations require `relative_to` because months and years
/// do not have fixed lengths.
pub fn add(
  first: Duration,
  second: Duration,
  relative_to: Option(RelativeTo),
) -> Result(Duration, temporal.Error) {
  use first <- result.try(validate(first))
  use second <- result.try(validate(second))
  case is_zero(second) {
    True -> Ok(first)
    False ->
      case is_zero(first) {
        True -> Ok(second)
        False -> add_nonzero(first, second, relative_to)
      }
  }
}

fn add_nonzero(
  first: Duration,
  second: Duration,
  relative_to: Option(RelativeTo),
) -> Result(Duration, temporal.Error) {
  let has_calendar = has_calendar_units(first) || has_calendar_units(second)
  case has_calendar, relative_to, first.is_negative == second.is_negative {
    True, None, _ -> Error(temporal.MissingRelativeTo)
    True, Some(_), True -> add_same_sign_calendar(first, second)
    True, Some(_), False -> {
      use first_total <- result.try(comparable_nanoseconds(first, relative_to))
      use second_total <- result.try(comparable_nanoseconds(second, relative_to))
      from_total_nanoseconds(first_total + second_total, Day)
    }
    False, _, _ -> {
      let largest = largest_fixed_unit(first, second)
      from_total_nanoseconds(
        fixed_nanoseconds(first) + fixed_nanoseconds(second),
        largest,
      )
    }
  }
}

fn add_same_sign_calendar(
  first: Duration,
  second: Duration,
) -> Result(Duration, temporal.Error) {
  let time_largest = case first.days > 0 || second.days > 0 {
    True -> Day
    False -> largest_fixed_unit(first, second)
  }
  use time <- result.try(from_total_nanoseconds(
    time_nanoseconds(first) + time_nanoseconds(second),
    time_largest,
  ))
  validate(Duration(
    is_negative: first.is_negative,
    years: first.years + second.years,
    months: first.months + second.months,
    weeks: first.weeks + second.weeks,
    days: first.days + second.days + time.days,
    hours: time.hours,
    minutes: time.minutes,
    seconds: time.seconds,
    milliseconds: time.milliseconds,
    microseconds: time.microseconds,
    nanoseconds: time.nanoseconds,
  ))
}

/// Subtracts one duration from another.
pub fn subtract(
  first: Duration,
  second: Duration,
  relative_to: Option(RelativeTo),
) -> Result(Duration, temporal.Error) {
  add(first, negated(second), relative_to)
}

/// Returns the duration with its sign reversed.
pub fn negated(duration: Duration) -> Duration {
  case is_zero(duration) {
    True -> Duration(..duration, is_negative: False)
    False -> Duration(..duration, is_negative: !duration.is_negative)
  }
}

/// Returns the non-negative magnitude of a duration.
pub fn absolute(duration: Duration) -> Duration {
  Duration(..duration, is_negative: False)
}

/// Rounds a duration to a positive increment of `smallest_unit`.
pub fn round(
  duration: Duration,
  smallest_unit: Unit,
  largest_unit: Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
  relative_to: Option(RelativeTo),
) -> Result(Duration, temporal.Error) {
  use duration <- result.try(validate(duration))
  case
    rounding_increment <= 0
    || unit_rank(largest_unit) > unit_rank(smallest_unit)
  {
    True ->
      Error(temporal.InvalidOption(option: temporal.RoundingIncrementOption))
    False ->
      case unit_nanoseconds(smallest_unit), unit_nanoseconds(largest_unit) {
        Some(smallest_ns), Some(_) -> {
          use total <- result.try(comparable_nanoseconds(duration, relative_to))
          let increment = smallest_ns * rounding_increment
          let rounded = round_to_increment(total, increment, rounding_mode)
          from_total_nanoseconds(rounded, largest_unit)
        }
        _, _ ->
          case relative_to {
            None -> Error(temporal.MissingRelativeTo)
            Some(_) ->
              Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
          }
      }
  }
}

/// Returns a duration expressed as a possibly fractional unit.
pub fn total(
  duration: Duration,
  unit: Unit,
  relative_to: Option(RelativeTo),
) -> Result(Float, temporal.Error) {
  use duration <- result.try(validate(duration))
  case unit_nanoseconds(unit) {
    Some(divisor) -> {
      use total <- result.try(comparable_nanoseconds(duration, relative_to))
      Ok(int.to_float(total) /. int.to_float(divisor))
    }
    None ->
      case relative_to {
        None -> Error(temporal.MissingRelativeTo)
        Some(relative) -> total_calendar(duration, unit, relative)
      }
  }
}

/// Serializes with explicit precision and rounding options.
pub fn to_iso_8601_with_options(
  duration: Duration,
  options: ToStringOptions,
) -> Result(String, temporal.Error) {
  use duration <- result.try(validate(duration))
  let ToStringOptions(precision:, smallest_unit:, rounding_mode:, ..) = options
  case precision {
    Digits(digits) if digits < 0 || digits > 9 ->
      Error(temporal.InvalidOption(option: temporal.ToStringOptions))
    _ ->
      case smallest_unit {
        None -> Ok(serialize(duration, precision))
        Some(unit) ->
          case unit_nanoseconds(unit) {
            None ->
              Error(temporal.InvalidOption(option: temporal.ToStringOptions))
            Some(_) -> {
              let digits = case precision {
                AutoPrecision -> precision_for_unit(unit)
                Digits(value) -> value
              }
              use rounded <- result.try(round(
                duration,
                unit,
                largest_present_unit(duration),
                1,
                rounding_mode,
                None,
              ))
              Ok(serialize(rounded, Digits(digits)))
            }
          }
      }
  }
}

fn serialize(duration: Duration, precision: Precision) -> String {
  let duration = canonicalize_zero(duration)
  let #(serialized_seconds, serialized_fraction) =
    serialized_second_parts(duration)
  let sign = case duration.is_negative, is_zero(duration) {
    True, False -> "-"
    _, _ -> ""
  }
  let date =
    append_component("", duration.years, "Y")
    |> append_component(duration.months, "M")
    |> append_component(duration.weeks, "W")
    |> append_component(duration.days, "D")
  let has_subseconds = serialized_fraction > 0
  let has_time =
    duration.hours > 0
    || duration.minutes > 0
    || serialized_seconds > 0
    || has_subseconds
  let hours = append_component("", duration.hours, "H")
  let minutes = append_component(hours, duration.minutes, "M")
  let seconds = case
    serialized_seconds > 0 || has_subseconds || !has_time && date == ""
  {
    True ->
      minutes
      <> serialize_seconds(serialized_seconds, serialized_fraction, precision)
    False -> minutes
  }
  sign
  <> "P"
  <> date
  <> case seconds != "" {
    True -> "T" <> seconds
    False -> ""
  }
}

fn append_component(acc: String, value: Int, suffix: String) -> String {
  case value {
    0 -> acc
    _ -> acc <> int.to_string(value) <> suffix
  }
}

fn serialized_second_parts(duration: Duration) -> #(Int, Int) {
  let subsecond_nanoseconds =
    duration.milliseconds
    * 1_000_000
    + duration.microseconds
    * 1000
    + duration.nanoseconds
  #(
    duration.seconds + subsecond_nanoseconds / nanoseconds_per_second,
    subsecond_nanoseconds % nanoseconds_per_second,
  )
}

fn serialize_seconds(
  seconds: Int,
  fraction: Int,
  precision: Precision,
) -> String {
  let digits = left_pad(int.to_string(fraction), 9, "0")
  let shown = case precision {
    AutoPrecision -> trim_trailing_zeroes(digits)
    Digits(count) -> take_characters(digits, count)
  }
  int.to_string(seconds)
  <> case shown {
    "" -> "S"
    _ -> "." <> shown <> "S"
  }
}

fn left_pad(value: String, width: Int, character: String) -> String {
  case string.length(value) >= width {
    True -> value
    False -> left_pad(character <> value, width, character)
  }
}

fn trim_trailing_zeroes(value: String) -> String {
  value
  |> string.to_graphemes()
  |> list.reverse()
  |> drop_leading_zeroes()
  |> list.reverse()
  |> string.join("")
}

fn drop_leading_zeroes(chars: List(String)) -> List(String) {
  case chars {
    ["0", ..rest] -> drop_leading_zeroes(rest)
    _ -> chars
  }
}

fn take_characters(value: String, count: Int) -> String {
  value |> string.to_graphemes() |> list.take(count) |> string.join("")
}

fn canonicalize_zero(duration: Duration) -> Duration {
  case is_zero(duration) {
    True -> Duration(..duration, is_negative: False)
    False -> duration
  }
}

fn is_zero(duration: Duration) -> Bool {
  duration.years == 0
  && duration.months == 0
  && duration.weeks == 0
  && duration.days == 0
  && duration.hours == 0
  && duration.minutes == 0
  && duration.seconds == 0
  && duration.milliseconds == 0
  && duration.microseconds == 0
  && duration.nanoseconds == 0
}

fn has_calendar_units(duration: Duration) -> Bool {
  duration.years > 0 || duration.months > 0 || duration.weeks > 0
}

fn sign_multiplier(duration: Duration) -> Int {
  case duration.is_negative {
    True -> -1
    False -> 1
  }
}

fn time_nanoseconds(duration: Duration) -> Int {
  let magnitude =
    duration.hours
    * nanoseconds_per_hour
    + duration.minutes
    * nanoseconds_per_minute
    + duration.seconds
    * nanoseconds_per_second
    + duration.milliseconds
    * nanoseconds_per_millisecond
    + duration.microseconds
    * nanoseconds_per_microsecond
    + duration.nanoseconds
  magnitude * sign_multiplier(duration)
}

fn fixed_nanoseconds(duration: Duration) -> Int {
  let magnitude =
    duration.weeks
    * nanoseconds_per_week
    + duration.days
    * nanoseconds_per_day
    + duration.hours
    * nanoseconds_per_hour
    + duration.minutes
    * nanoseconds_per_minute
    + duration.seconds
    * nanoseconds_per_second
    + duration.milliseconds
    * nanoseconds_per_millisecond
    + duration.microseconds
    * nanoseconds_per_microsecond
    + duration.nanoseconds
  magnitude * sign_multiplier(duration)
}

fn comparable_nanoseconds(
  duration: Duration,
  relative_to: Option(RelativeTo),
) -> Result(Int, temporal.Error) {
  case has_calendar_units(duration) {
    False -> Ok(fixed_nanoseconds(duration))
    True ->
      case relative_to {
        None -> Error(temporal.MissingRelativeTo)
        Some(relative) -> {
          let day_count = calendar_days(duration, relative)
          let magnitude =
            day_count
            * nanoseconds_per_day
            + duration.hours
            * nanoseconds_per_hour
            + duration.minutes
            * nanoseconds_per_minute
            + duration.seconds
            * nanoseconds_per_second
            + duration.milliseconds
            * nanoseconds_per_millisecond
            + duration.microseconds
            * nanoseconds_per_microsecond
            + duration.nanoseconds
          Ok(magnitude * sign_multiplier(duration))
        }
      }
  }
}

fn calendar_days(duration: Duration, relative: RelativeTo) -> Int {
  let RelativeTo(year: start_year, month: start_month, day: start_day, ..) =
    relative
  let total_month = start_month - 1 + duration.years * 12 + duration.months
  let year = start_year + total_month / 12
  let month = total_month % 12 + 1
  let day = int.min(start_day, days_in_month(year, month))
  iso_date_to_epoch_days(year, month, day)
  - iso_date_to_epoch_days(start_year, start_month, start_day)
  + duration.weeks
  * 7
  + duration.days
}

fn total_calendar(
  duration: Duration,
  unit: Unit,
  relative: RelativeTo,
) -> Result(Float, temporal.Error) {
  let days =
    int.to_float(calendar_days(duration, relative))
    +. int.to_float(time_nanoseconds(absolute(duration)))
    /. int.to_float(nanoseconds_per_day)
  let signed_days = case duration.is_negative {
    True -> 0.0 -. days
    False -> days
  }
  case unit {
    Year -> Ok(signed_days /. 365.2425)
    Month -> Ok(signed_days /. { 365.2425 /. 12.0 })
    _ -> Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
  }
}

fn from_total_nanoseconds(
  total: Int,
  largest_unit: Unit,
) -> Result(Duration, temporal.Error) {
  let is_negative = total < 0
  let magnitude = int.absolute_value(total)
  let #(weeks, after_weeks) = case largest_unit {
    Week -> #(
      magnitude / nanoseconds_per_week,
      magnitude % nanoseconds_per_week,
    )
    _ -> #(0, magnitude)
  }
  let #(days, after_days) = case largest_unit {
    Week | Day -> #(
      after_weeks / nanoseconds_per_day,
      after_weeks % nanoseconds_per_day,
    )
    _ -> #(0, after_weeks)
  }
  let #(hours, after_hours) = case unit_rank(largest_unit) <= unit_rank(Hour) {
    True -> #(
      after_days / nanoseconds_per_hour,
      after_days % nanoseconds_per_hour,
    )
    False -> #(0, after_days)
  }
  let #(minutes, after_minutes) = case
    unit_rank(largest_unit) <= unit_rank(Minute)
  {
    True -> #(
      after_hours / nanoseconds_per_minute,
      after_hours % nanoseconds_per_minute,
    )
    False -> #(0, after_hours)
  }
  let #(seconds, after_seconds) = case
    unit_rank(largest_unit) <= unit_rank(Second)
  {
    True -> #(
      after_minutes / nanoseconds_per_second,
      after_minutes % nanoseconds_per_second,
    )
    False -> #(0, after_minutes)
  }
  let milliseconds = after_seconds / nanoseconds_per_millisecond
  let microseconds =
    after_seconds % nanoseconds_per_millisecond / nanoseconds_per_microsecond
  let nanoseconds = after_seconds % nanoseconds_per_microsecond
  validate(Duration(
    is_negative: is_negative,
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

fn largest_fixed_unit(first: Duration, second: Duration) -> Unit {
  case first.weeks > 0 || second.weeks > 0 {
    True -> Week
    False ->
      case first.days > 0 || second.days > 0 {
        True -> Day
        False ->
          case first.hours > 0 || second.hours > 0 {
            True -> Hour
            False ->
              case first.minutes > 0 || second.minutes > 0 {
                True -> Minute
                False ->
                  case first.seconds > 0 || second.seconds > 0 {
                    True -> Second
                    False ->
                      case first.milliseconds > 0 || second.milliseconds > 0 {
                        True -> Millisecond
                        False ->
                          case
                            first.microseconds > 0 || second.microseconds > 0
                          {
                            True -> Microsecond
                            False -> Nanosecond
                          }
                      }
                  }
              }
          }
      }
  }
}

fn largest_present_unit(duration: Duration) -> Unit {
  case duration.years > 0 {
    True -> Year
    False ->
      case duration.months > 0 {
        True -> Month
        False -> largest_fixed_unit(duration, duration)
      }
  }
}

fn unit_rank(unit: Unit) -> Int {
  case unit {
    Year -> 0
    Month -> 1
    Week -> 2
    Day -> 3
    Hour -> 4
    Minute -> 5
    Second -> 6
    Millisecond -> 7
    Microsecond -> 8
    Nanosecond -> 9
  }
}

fn unit_nanoseconds(unit: Unit) -> Option(Int) {
  case unit {
    Year | Month -> None
    Week -> Some(nanoseconds_per_week)
    Day -> Some(nanoseconds_per_day)
    Hour -> Some(nanoseconds_per_hour)
    Minute -> Some(nanoseconds_per_minute)
    Second -> Some(nanoseconds_per_second)
    Millisecond -> Some(nanoseconds_per_millisecond)
    Microsecond -> Some(nanoseconds_per_microsecond)
    Nanosecond -> Some(1)
  }
}

fn precision_for_unit(unit: Unit) -> Int {
  case unit {
    Second -> 0
    Millisecond -> 3
    Microsecond -> 6
    Nanosecond -> 9
    _ -> 0
  }
}

fn round_to_increment(
  value: Int,
  increment: Int,
  mode: temporal.RoundingMode,
) -> Int {
  let negative = value < 0
  let magnitude = int.absolute_value(value)
  let quotient = magnitude / increment
  let remainder = magnitude % increment
  let increase = case remainder == 0 {
    True -> False
    False ->
      case mode {
        temporal.Trunc -> False
        temporal.Expand -> True
        temporal.Ceil -> !negative
        temporal.Floor -> negative
        temporal.HalfExpand -> remainder * 2 >= increment
        temporal.HalfTrunc -> remainder * 2 > increment
        temporal.HalfCeil ->
          remainder * 2 > increment || remainder * 2 == increment && !negative
        temporal.HalfFloor ->
          remainder * 2 > increment || remainder * 2 == increment && negative
        temporal.HalfEven ->
          remainder * 2 > increment
          || remainder * 2 == increment
          && quotient % 2 == 1
      }
  }
  let rounded = case increase {
    True -> { quotient + 1 } * increment
    False -> quotient * increment
  }
  case negative {
    True -> 0 - rounded
    False -> rounded
  }
}

fn parse_relative_date(value: String) -> Result(#(Int, Int, Int), Nil) {
  case string.to_graphemes(value) {
    [y1, y2, y3, y4, "-", m1, m2, "-", d1, d2, ..rest] -> {
      use year <- result.try(int.base_parse(y1 <> y2 <> y3 <> y4, 10))
      use month <- result.try(int.base_parse(m1 <> m2, 10))
      use day <- result.try(int.base_parse(d1 <> d2, 10))
      case valid_relative_suffix(rest) {
        True -> Ok(#(year, month, day))
        False -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn valid_relative_suffix(chars: List(String)) -> Bool {
  case chars {
    [] -> True
    ["T", ..] -> True
    ["[", ..] -> True
    _ -> False
  }
}

fn valid_iso_date(year: Int, month: Int, day: Int) -> Bool {
  year >= 1
  && year <= 9999
  && month >= 1
  && month <= 12
  && day >= 1
  && day <= days_in_month(year, month)
}

fn days_in_month(year: Int, month: Int) -> Int {
  case month {
    2 ->
      case is_leap_year(year) {
        True -> 29
        False -> 28
      }
    4 | 6 | 9 | 11 -> 30
    _ -> 31
  }
}

fn is_leap_year(year: Int) -> Bool {
  year % 4 == 0 && { year % 100 != 0 || year % 400 == 0 }
}

fn iso_date_to_epoch_days(year: Int, month: Int, day: Int) -> Int {
  let adjusted_year = case month <= 2 {
    True -> year - 1
    False -> year
  }
  let era = adjusted_year / 400
  let year_of_era = adjusted_year - era * 400
  let adjusted_month = case month > 2 {
    True -> month - 3
    False -> month + 9
  }
  let day_of_year = { 153 * adjusted_month + 2 } / 5 + day - 1
  let day_of_era =
    year_of_era * 365 + year_of_era / 4 - year_of_era / 100 + day_of_year
  era * 146_097 + day_of_era - 719_468
}
