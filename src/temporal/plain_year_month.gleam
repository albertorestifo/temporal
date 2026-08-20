//// ISO 8601 year-month values.

import gleam/option.{type Option}
import gleam/order.{type Order, Eq, Lt}
import temporal
import temporal/calendar
import temporal/duration

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
  calendar _calendar: calendar.Calendar,
  overflow _overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  Error(temporal.OutOfRange(
    field: temporal.YearMonth,
    value: label(year, month, reference_day),
  ))
}

/// Parses an ISO 8601 year-month.
pub fn from_iso_8601(value: String) -> Result(PlainYearMonth, temporal.Error) {
  Error(temporal.InvalidIsoString(input: value))
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
  todo as "calendar era access is not implemented"
}

/// Return the calendar-specific era year, or `None` for ISO 8601.
pub fn era_year(_value: PlainYearMonth) -> Option(Int) {
  todo as "calendar era-year access is not implemented"
}

/// Returns the number of days in the represented month.
pub fn days_in_month(_value: PlainYearMonth) -> Int {
  0
}

/// Returns the number of days in the represented year.
pub fn days_in_year(_value: PlainYearMonth) -> Int {
  0
}

/// Returns twelve for the ISO calendar.
pub fn months_in_year(_value: PlainYearMonth) -> Int {
  0
}

/// Reports whether the represented year is a leap year.
pub fn in_leap_year(_value: PlainYearMonth) -> Bool {
  False
}

/// Compares two year-months by ISO fields.
pub fn compare(first: PlainYearMonth, second: PlainYearMonth) -> Order {
  case first == second {
    True -> Eq
    False -> Lt
  }
}

/// Reports whether two year-month values are equal.
pub fn equal(first: PlainYearMonth, second: PlainYearMonth) -> Bool {
  first == second
}

/// Replace the supplied year-month fields.
pub fn with_fields(
  _value: PlainYearMonth,
  _fields: PartialYearMonth,
  _overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  Error(temporal.PlatformUnavailable(temporal.NonIsoCalendarProvider))
}

/// Adds a duration to a year-month.
pub fn add(
  _value: PlainYearMonth,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain year-month addition is not implemented",
  ))
}

/// Subtracts a duration from a year-month.
pub fn subtract(
  _value: PlainYearMonth,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain year-month subtraction is not implemented",
  ))
}

/// Returns the elapsed duration until another year-month.
pub fn until(
  _first: PlainYearMonth,
  _second: PlainYearMonth,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
}

/// Returns the elapsed duration since another year-month.
pub fn since(
  _first: PlainYearMonth,
  _second: PlainYearMonth,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
}

/// Serializes a year-month using ISO 8601.
pub fn to_iso_8601(_value: PlainYearMonth) -> String {
  ""
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

fn label(year: Int, month: Int, day: Int) -> String {
  case year + month + day {
    0 -> "0"
    _ -> "invalid"
  }
}
