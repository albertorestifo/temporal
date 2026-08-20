//// Shared ISO 8601 calendar and clock arithmetic for plain Temporal values.

import gleam/int
import gleam/string
import temporal

/// Validated ISO date fields.
pub type Date {
  Date(year: Int, month: Int, day: Int)
}

/// Validated ISO time fields.
pub type Time {
  Time(
    hour: Int,
    minute: Int,
    second: Int,
    millisecond: Int,
    microsecond: Int,
    nanosecond: Int,
  )
}

/// Reports whether a year is an ISO leap year.
pub fn is_leap_year(year: Int) -> Bool {
  divisible(year, 4) && { !divisible(year, 100) || divisible(year, 400) }
}

/// Returns the number of days in an ISO month.
pub fn days_in_month(year: Int, month: Int) -> Int {
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

/// Validates or constrains ISO date fields.
pub fn regulate_date(
  year: Int,
  month: Int,
  day: Int,
  overflow: temporal.Overflow,
) -> Result(Date, temporal.Error) {
  case overflow {
    temporal.Constrain -> {
      let constrained_month = clamp(month, 1, 12)
      Ok(Date(
        year,
        constrained_month,
        clamp(day, 1, days_in_month(year, constrained_month)),
      ))
    }
    temporal.Reject ->
      case month >= 1 && month <= 12 {
        False ->
          Error(temporal.OutOfRange(temporal.Month, int.to_string(month)))
        True ->
          case day >= 1 && day <= days_in_month(year, month) {
            True -> Ok(Date(year, month, day))
            False ->
              Error(temporal.OutOfRange(temporal.Day, int.to_string(day)))
          }
      }
  }
}

/// Validates or constrains ISO clock fields.
pub fn regulate_time(
  hour: Int,
  minute: Int,
  second: Int,
  millisecond: Int,
  microsecond: Int,
  nanosecond: Int,
  overflow: temporal.Overflow,
) -> Result(Time, temporal.Error) {
  case overflow {
    temporal.Constrain ->
      Ok(Time(
        clamp(hour, 0, 23),
        clamp(minute, 0, 59),
        clamp(second, 0, 59),
        clamp(millisecond, 0, 999),
        clamp(microsecond, 0, 999),
        clamp(nanosecond, 0, 999),
      ))
    temporal.Reject ->
      case
        field_in_range(hour, 0, 23, temporal.Hour),
        field_in_range(minute, 0, 59, temporal.Minute),
        field_in_range(second, 0, 59, temporal.Second),
        field_in_range(millisecond, 0, 999, temporal.Millisecond),
        field_in_range(microsecond, 0, 999, temporal.Microsecond),
        field_in_range(nanosecond, 0, 999, temporal.Nanosecond)
      {
        Ok(_), Ok(_), Ok(_), Ok(_), Ok(_), Ok(_) ->
          Ok(Time(hour, minute, second, millisecond, microsecond, nanosecond))
        Error(error), _, _, _, _, _
        | _, Error(error), _, _, _, _
        | _, _, Error(error), _, _, _
        | _, _, _, Error(error), _, _
        | _, _, _, _, Error(error), _
        | _, _, _, _, _, Error(error)
        -> Error(error)
      }
  }
}

/// Parses the supported ISO calendar-date representation.
pub fn parse_date(value: String) -> Result(Date, temporal.Error) {
  case string.split(value, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(y), Ok(m), Ok(d) ->
          regulate_date(y, m, d, temporal.Reject)
          |> map_parse_error(value)
        _, _, _ -> invalid(value)
      }
    ["", year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(y), Ok(m), Ok(d) ->
          regulate_date(y * -1, m, d, temporal.Reject)
          |> map_parse_error(value)
        _, _, _ -> invalid(value)
      }
    _ -> invalid(value)
  }
}

/// Parses the supported ISO wall-clock representation.
pub fn parse_time(value: String) -> Result(Time, temporal.Error) {
  case string.split(value, ":") {
    [hour, minute] ->
      case int.parse(hour), int.parse(minute) {
        Ok(h), Ok(m) ->
          regulate_time(h, m, 0, 0, 0, 0, temporal.Reject)
          |> map_parse_error(value)
        _, _ -> invalid(value)
      }
    [hour, minute, seconds] ->
      case int.parse(hour), int.parse(minute), parse_seconds(seconds) {
        Ok(h), Ok(m), Ok(#(s, ms, us, ns)) ->
          regulate_time(h, m, s, ms, us, ns, temporal.Reject)
          |> map_parse_error(value)
        _, _, _ -> invalid(value)
      }
    _ -> invalid(value)
  }
}

/// Formats an ISO date.
pub fn format_date(date: Date) -> String {
  let Date(year, month, day) = date
  format_year(year) <> "-" <> pad2(month) <> "-" <> pad2(day)
}

/// Formats an ISO year-month.
pub fn format_year_month(year: Int, month: Int) -> String {
  format_year(year) <> "-" <> pad2(month)
}

/// Formats an ISO month-day.
pub fn format_month_day(month: Int, day: Int) -> String {
  pad2(month) <> "-" <> pad2(day)
}

/// Formats an ISO time with the shortest exact fractional part.
pub fn format_time(time: Time) -> String {
  let Time(hour, minute, second, millisecond, microsecond, nanosecond) = time
  let fraction = pad3(millisecond) <> pad3(microsecond) <> pad3(nanosecond)
  let trimmed = trim_fraction(fraction)
  pad2(hour)
  <> ":"
  <> pad2(minute)
  <> ":"
  <> pad2(second)
  <> case trimmed {
    "" -> ""
    value -> "." <> value
  }
}

/// Returns the ISO ordinal day.
pub fn day_of_year(date: Date) -> Int {
  let Date(year, month, day) = date
  day + days_before_month(year, month)
}

/// Returns the ISO weekday from Monday=1 through Sunday=7.
pub fn day_of_week(date: Date) -> Int {
  positive_mod(days_from_civil(date) + 3, 7) + 1
}

/// Returns the ISO week-numbering year and week.
pub fn iso_week(date: Date) -> #(Int, Int) {
  let weekday = day_of_week(date)
  let thursday = add_days(date, 4 - weekday)
  let Date(week_year, _, _) = thursday
  let week = floor_div(day_of_year(thursday) - 1, 7) + 1
  #(week_year, week)
}

/// Adds a number of calendar days.
pub fn add_days(date: Date, amount: Int) -> Date {
  civil_from_days(days_from_civil(date) + amount)
}

/// Adds years, months, weeks, and days in Temporal date order.
pub fn add_date(
  date: Date,
  years: Int,
  months: Int,
  weeks: Int,
  days: Int,
  overflow: temporal.Overflow,
) -> Result(Date, temporal.Error) {
  let Date(year, month, day) = date
  let month_index = year * 12 + month - 1 + years * 12 + months
  let balanced_year = floor_div(month_index, 12)
  let balanced_month = positive_mod(month_index, 12) + 1
  use regulated <- result_try(regulate_date(
    balanced_year,
    balanced_month,
    day,
    overflow,
  ))
  Ok(add_days(regulated, weeks * 7 + days))
}

/// Returns whole days between two ISO dates.
pub fn days_between(first: Date, second: Date) -> Int {
  days_from_civil(second) - days_from_civil(first)
}

/// Converts a clock value to nanoseconds since midnight.
pub fn time_to_nanoseconds(time: Time) -> Int {
  let Time(hour, minute, second, millisecond, microsecond, nanosecond) = time
  hour
  * 3_600_000_000_000
  + minute
  * 60_000_000_000
  + second
  * 1_000_000_000
  + millisecond
  * 1_000_000
  + microsecond
  * 1000
  + nanosecond
}

/// Balances nanoseconds into a day carry and wall-clock time.
pub fn nanoseconds_to_time(total: Int) -> #(Int, Time) {
  let day_ns = 86_400_000_000_000
  let day = floor_div(total, day_ns)
  let within = positive_mod(total, day_ns)
  let hour = floor_div(within, 3_600_000_000_000)
  let after_hour = positive_mod(within, 3_600_000_000_000)
  let minute = floor_div(after_hour, 60_000_000_000)
  let after_minute = positive_mod(after_hour, 60_000_000_000)
  let second = floor_div(after_minute, 1_000_000_000)
  let after_second = positive_mod(after_minute, 1_000_000_000)
  let millisecond = floor_div(after_second, 1_000_000)
  let after_millisecond = positive_mod(after_second, 1_000_000)
  let microsecond = floor_div(after_millisecond, 1000)
  let nanosecond = positive_mod(after_millisecond, 1000)
  #(day, Time(hour, minute, second, millisecond, microsecond, nanosecond))
}

fn parse_seconds(value: String) -> Result(#(Int, Int, Int, Int), Nil) {
  case string.split(value, ".") {
    [whole] -> {
      use second <- nil_try(int.parse(whole))
      Ok(#(second, 0, 0, 0))
    }
    [whole, fraction] ->
      case string.length(fraction) >= 1 && string.length(fraction) <= 9 {
        False -> Error(Nil)
        True -> {
          use second <- nil_try(int.parse(whole))
          use digits <- nil_try(int.parse(fraction))
          let scaled = digits * power10(9 - string.length(fraction))
          Ok(#(
            second,
            floor_div(scaled, 1_000_000),
            floor_div(positive_mod(scaled, 1_000_000), 1000),
            positive_mod(scaled, 1000),
          ))
        }
      }
    _ -> Error(Nil)
  }
}

fn days_before_month(year: Int, month: Int) -> Int {
  let value = case month {
    1 -> 0
    2 -> 31
    3 -> 59
    4 -> 90
    5 -> 120
    6 -> 151
    7 -> 181
    8 -> 212
    9 -> 243
    10 -> 273
    11 -> 304
    _ -> 334
  }
  case month > 2 && is_leap_year(year) {
    True -> value + 1
    False -> value
  }
}

// Howard Hinnant's proleptic-Gregorian civil date algorithms.
fn days_from_civil(date: Date) -> Int {
  let Date(year, month, day) = date
  let adjusted_year = case month <= 2 {
    True -> year - 1
    False -> year
  }
  let era = floor_div(adjusted_year, 400)
  let year_of_era = adjusted_year - era * 400
  let shifted_month = case month > 2 {
    True -> month - 3
    False -> month + 9
  }
  let day_of_year = floor_div(153 * shifted_month + 2, 5) + day - 1
  let day_of_era =
    year_of_era
    * 365
    + floor_div(year_of_era, 4)
    - floor_div(year_of_era, 100)
    + day_of_year
  era * 146_097 + day_of_era - 719_468
}

fn civil_from_days(days: Int) -> Date {
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
  Date(year, month, day)
}

fn field_in_range(
  value: Int,
  minimum: Int,
  maximum: Int,
  field: temporal.Field,
) -> Result(Nil, temporal.Error) {
  case value >= minimum && value <= maximum {
    True -> Ok(Nil)
    False -> Error(temporal.OutOfRange(field, int.to_string(value)))
  }
}

fn invalid(value: String) -> Result(a, temporal.Error) {
  Error(temporal.InvalidIsoString(value))
}

fn map_parse_error(
  result: Result(a, temporal.Error),
  value: String,
) -> Result(a, temporal.Error) {
  case result {
    Ok(value) -> Ok(value)
    Error(_) -> invalid(value)
  }
}

fn pad2(value: Int) -> String {
  case value < 10 {
    True -> "0" <> int.to_string(value)
    False -> int.to_string(value)
  }
}

fn pad3(value: Int) -> String {
  case value < 10 {
    True -> "00" <> int.to_string(value)
    False ->
      case value < 100 {
        True -> "0" <> int.to_string(value)
        False -> int.to_string(value)
      }
  }
}

fn format_year(year: Int) -> String {
  case year >= 0 && year <= 9999 {
    True -> string.pad_start(int.to_string(year), 4, "0")
    False ->
      case year < 0 {
        True -> "-" <> string.pad_start(int.to_string(year * -1), 6, "0")
        False -> "+" <> string.pad_start(int.to_string(year), 6, "0")
      }
  }
}

fn trim_fraction(value: String) -> String {
  case string.ends_with(value, "0") {
    True -> trim_fraction(string.drop_end(value, 1))
    False -> value
  }
}

fn clamp(value: Int, minimum: Int, maximum: Int) -> Int {
  case value < minimum, value > maximum {
    True, _ -> minimum
    _, True -> maximum
    _, _ -> value
  }
}

fn divisible(value: Int, divisor: Int) -> Bool {
  positive_mod(value, divisor) == 0
}

fn floor_div(value: Int, divisor: Int) -> Int {
  let quotient = value / divisor
  case value < 0 && positive_mod(value, divisor) != 0 {
    True -> quotient - 1
    False -> quotient
  }
}

fn positive_mod(value: Int, divisor: Int) -> Int {
  let assert Ok(remainder) = int.modulo(value, divisor)
  remainder
}

fn power10(exponent: Int) -> Int {
  case exponent {
    0 -> 1
    _ -> 10 * power10(exponent - 1)
  }
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}

fn nil_try(
  result: Result(a, Nil),
  next: fn(a) -> Result(b, Nil),
) -> Result(b, Nil) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
