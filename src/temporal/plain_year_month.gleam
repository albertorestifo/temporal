//// ISO 8601 year-month values.

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/string
import temporal
import temporal/calendar
import temporal/duration
import temporal/internal/iso_plain as iso

/// A validated ISO year-month with a reference day.
pub opaque type PlainYearMonth {
  PlainYearMonth(year: Int, month: Int, reference_day: Int)
}

/// Optional year-month fields used by `with_fields`.
pub type PartialYearMonth {
  PartialYearMonth(
    year: Option(Int),
    month: Option(Int),
    month_code: Option(String),
  )
}

/// Builds an unvalidated year-month fixture for package tests.
@internal
pub fn fixture(
  year year: Int,
  month month: Int,
  reference_day reference_day: Int,
) -> PlainYearMonth {
  PlainYearMonth(year: year, month: month, reference_day: reference_day)
}

/// Constructs an ISO year-month.
pub fn new(
  year year: Int,
  month month: Int,
  reference_day reference_day: Int,
  calendar calendar_value: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  case calendar_value {
    calendar.Iso8601 -> {
      use date <- result_try(iso.regulate_date(
        year,
        month,
        reference_day,
        overflow,
      ))
      let iso.Date(year, month, reference_day) = date
      Ok(PlainYearMonth(year, month, reference_day))
    }
    _ -> Error(temporal.PlatformUnavailable(temporal.NonIsoCalendarProvider))
  }
}

/// Parses an ISO 8601 year-month.
pub fn from_iso_8601(value: String) -> Result(PlainYearMonth, temporal.Error) {
  case string.split(value, "-") {
    [year, month] ->
      case int.parse(year), int.parse(month) {
        Ok(year), Ok(month) ->
          new(year, month, 1, calendar.Iso8601, temporal.Reject)
          |> map_parse_error(value)
        _, _ -> Error(temporal.InvalidIsoString(value))
      }
    _ -> Error(temporal.InvalidIsoString(value))
  }
}

/// Returns the ISO year.
pub fn year(value: PlainYearMonth) -> Int {
  value.year
}

/// Returns the ISO month.
pub fn month(value: PlainYearMonth) -> Int {
  value.month
}

/// Returns the ISO month code.
pub fn month_code(value: PlainYearMonth) -> String {
  month_code_for(value.month)
}

/// Returns the calendar of this year-month.
pub fn calendar(_value: PlainYearMonth) -> calendar.Calendar {
  calendar.Iso8601
}

/// Return the calendar-specific era, or `None` for ISO 8601.
pub fn era(_value: PlainYearMonth) -> Option(calendar.Era) {
  None
}

/// Return the calendar-specific era year, or `None` for ISO 8601.
pub fn era_year(_value: PlainYearMonth) -> Option(Int) {
  None
}

/// Returns the number of days in the represented month.
pub fn days_in_month(value: PlainYearMonth) -> Int {
  iso.days_in_month(value.year, value.month)
}

/// Returns the number of days in the represented year.
pub fn days_in_year(value: PlainYearMonth) -> Int {
  case iso.is_leap_year(value.year) {
    True -> 366
    False -> 365
  }
}

/// Returns twelve for the ISO calendar.
pub fn months_in_year(_value: PlainYearMonth) -> Int {
  12
}

/// Reports whether the represented year is a leap year.
pub fn in_leap_year(value: PlainYearMonth) -> Bool {
  iso.is_leap_year(value.year)
}

/// Compares two year-months by ISO fields.
pub fn compare(first: PlainYearMonth, second: PlainYearMonth) -> Order {
  case int.compare(first.year, second.year) {
    order.Eq -> int.compare(first.month, second.month)
    other -> other
  }
}

/// Reports whether two year-month values are equal.
pub fn equal(first: PlainYearMonth, second: PlainYearMonth) -> Bool {
  first == second
}

/// Replace the supplied year-month fields.
pub fn with_fields(
  value: PlainYearMonth,
  fields: PartialYearMonth,
  overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  case
    fields.year == None && fields.month == None && fields.month_code == None
  {
    True -> Error(temporal.OutOfRange(temporal.YearMonth, "no fields"))
    False -> {
      use month <- result_try(resolve_month(
        fields.month,
        fields.month_code,
        value.month,
      ))
      new(
        option_or(fields.year, value.year),
        month,
        value.reference_day,
        calendar.Iso8601,
        overflow,
      )
    }
  }
}

/// Adds a duration to a year-month.
pub fn add(
  value: PlainYearMonth,
  amount: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  use _ <- result_try(validate_duration(amount))
  let sign = sign(amount)
  use date <- result_try(iso.add_date(
    iso.Date(value.year, value.month, value.reference_day),
    amount.years * sign,
    amount.months * sign,
    amount.weeks * sign,
    amount.days * sign,
    overflow,
  ))
  let iso.Date(year, month, day) = date
  Ok(PlainYearMonth(year, month, day))
}

/// Subtracts a duration from a year-month.
pub fn subtract(
  value: PlainYearMonth,
  amount: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  add(
    value,
    duration.Duration(..amount, is_negative: !amount.is_negative),
    overflow,
  )
}

/// Returns the elapsed duration until another year-month.
pub fn until(
  first: PlainYearMonth,
  second: PlainYearMonth,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  let months = { second.year - first.year } * 12 + second.month - first.month
  Ok(duration_from_months(months))
}

/// Returns the elapsed duration since another year-month.
pub fn since(
  first: PlainYearMonth,
  second: PlainYearMonth,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  until(second, first, options)
}

/// Serializes a year-month using ISO 8601.
pub fn to_iso_8601(value: PlainYearMonth) -> String {
  iso.format_year_month(value.year, value.month)
}

fn month_code_for(month: Int) -> String {
  case month {
    1 -> "M01"
    2 -> "M02"
    3 -> "M03"
    4 -> "M04"
    5 -> "M05"
    6 -> "M06"
    7 -> "M07"
    8 -> "M08"
    9 -> "M09"
    10 -> "M10"
    11 -> "M11"
    _ -> "M12"
  }
}

fn month_code_number(code: String) -> Int {
  case code {
    "M01" -> 1
    "M02" -> 2
    "M03" -> 3
    "M04" -> 4
    "M05" -> 5
    "M06" -> 6
    "M07" -> 7
    "M08" -> 8
    "M09" -> 9
    "M10" -> 10
    "M11" -> 11
    "M12" -> 12
    _ -> 0
  }
}

fn resolve_month(
  month: Option(Int),
  code: Option(String),
  fallback: Int,
) -> Result(Int, temporal.Error) {
  case month, code {
    None, None -> Ok(fallback)
    Some(month), None -> Ok(month)
    None, Some(code) ->
      case month_code_number(code) {
        0 -> Error(temporal.OutOfRange(temporal.Month, code))
        month -> Ok(month)
      }
    Some(month), Some(code) ->
      case month_code_number(code) == month {
        True -> Ok(month)
        False -> Error(temporal.OutOfRange(temporal.Month, code))
      }
  }
}

fn option_or(value: Option(a), fallback: a) -> a {
  case value {
    Some(value) -> value
    None -> fallback
  }
}

fn sign(value: duration.Duration) -> Int {
  case value.is_negative {
    True -> -1
    False -> 1
  }
}

fn validate_duration(value: duration.Duration) -> Result(Nil, temporal.Error) {
  case
    value.years >= 0
    && value.months >= 0
    && value.weeks >= 0
    && value.days >= 0
    && value.hours == 0
    && value.minutes == 0
    && value.seconds == 0
    && value.milliseconds == 0
    && value.microseconds == 0
    && value.nanoseconds == 0
  {
    True -> Ok(Nil)
    False ->
      Error(temporal.InvalidDuration("invalid plain year-month duration"))
  }
}

fn duration_from_months(months: Int) -> duration.Duration {
  let magnitude = int.absolute_value(months)
  duration.Duration(
    is_negative: months < 0,
    years: magnitude / 12,
    months: modulo(magnitude, 12),
    weeks: 0,
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
}

fn modulo(value: Int, divisor: Int) -> Int {
  let assert Ok(result) = int.modulo(value, divisor)
  result
}

fn map_parse_error(
  result: Result(a, temporal.Error),
  input: String,
) -> Result(a, temporal.Error) {
  case result {
    Ok(value) -> Ok(value)
    Error(_) -> Error(temporal.InvalidIsoString(input))
  }
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
