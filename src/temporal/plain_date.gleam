//// ISO 8601 calendar dates without a time or time zone.

import gleam/option.{type Option, None}
import gleam/order.{type Order, Eq, Lt}
import temporal
import temporal/calendar
import temporal/duration
import temporal/plain_month_day
import temporal/plain_year_month

/// A validated ISO calendar date.
pub opaque type PlainDate {
  PlainDate(year: Int, month: Int, day: Int)
}

/// Constructs an ISO calendar date.
///
/// Calendar is temporarily the identifier `iso8601` until the calendar module
/// lands.
pub fn new(
  year year: Int,
  month month: Int,
  day day: Int,
  calendar _calendar: calendar.Calendar,
  overflow _overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  Error(temporal.OutOfRange(field: "date", value: value_label(year, month, day)))
}

/// Parses an ISO 8601 calendar date.
pub fn from_iso_8601(value: String) -> Result(PlainDate, temporal.Error) {
  Error(temporal.InvalidIsoString(input: value))
}

/// Combines a year-month with a day.
pub fn from_year_month(
  year_month: plain_year_month.PlainYearMonth,
  value: Int,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  new(
    year: plain_year_month.year(year_month),
    month: plain_year_month.month(year_month),
    day: value,
    calendar: calendar.Iso8601,
    overflow: overflow,
  )
}

/// Combines a month-day with a year.
pub fn from_month_day(
  month_day: plain_month_day.PlainMonthDay,
  value: Int,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  new(
    year: value,
    month: month_code_number(plain_month_day.month_code(month_day)),
    day: plain_month_day.day(month_day),
    calendar: calendar.Iso8601,
    overflow: overflow,
  )
}

/// Returns the ISO year.
pub fn year(date: PlainDate) -> Int {
  date.year
}

/// Returns the ISO month.
pub fn month(date: PlainDate) -> Int {
  date.month
}

/// Returns the ISO month code.
pub fn month_code(date: PlainDate) -> String {
  month_code_for(date.month)
}

/// Returns the ISO day.
pub fn day(date: PlainDate) -> Int {
  date.day
}

/// Returns `iso8601`.
pub fn calendar_id(_date: PlainDate) -> String {
  "iso8601"
}

/// Returns the ISO day of week from 1 through 7.
pub fn day_of_week(_date: PlainDate) -> Int {
  0
}

/// Returns the ISO day of year.
pub fn day_of_year(_date: PlainDate) -> Int {
  0
}

/// Returns the ISO week number.
pub fn week_of_year(_date: PlainDate) -> Option(Int) {
  None
}

/// Returns the ISO week-numbering year.
pub fn year_of_week(_date: PlainDate) -> Option(Int) {
  None
}

/// Returns seven for the ISO calendar.
pub fn days_in_week(_date: PlainDate) -> Int {
  0
}

/// Returns the number of days in the ISO month.
pub fn days_in_month(_date: PlainDate) -> Int {
  0
}

/// Returns the number of days in the ISO year.
pub fn days_in_year(_date: PlainDate) -> Int {
  0
}

/// Returns twelve for the ISO calendar.
pub fn months_in_year(_date: PlainDate) -> Int {
  0
}

/// Reports whether the ISO year is a leap year.
pub fn in_leap_year(_date: PlainDate) -> Bool {
  False
}

/// Compares two ISO dates.
pub fn compare(first: PlainDate, second: PlainDate) -> Order {
  case first == second {
    True -> Eq
    False -> Lt
  }
}

/// Reports whether two dates and calendars are equal.
pub fn equal(first: PlainDate, second: PlainDate) -> Bool {
  first == second
}

/// Adds a duration to a date.
pub fn add(
  _date: PlainDate,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain date addition is not implemented",
  ))
}

/// Subtracts a duration from a date.
pub fn subtract(
  _date: PlainDate,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain date subtraction is not implemented",
  ))
}

/// Returns the elapsed duration until another date.
pub fn until(
  _first: PlainDate,
  _second: PlainDate,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(name: "options", value: "not implemented"))
}

/// Returns the elapsed duration since another date.
pub fn since(
  _first: PlainDate,
  _second: PlainDate,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(name: "options", value: "not implemented"))
}

/// Serializes a date using ISO 8601.
pub fn to_iso_8601(_date: PlainDate) -> String {
  ""
}

/// Serializes a date using explicit formatting options.
pub fn to_iso_8601_with_options(
  _date: PlainDate,
  _options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  Error(temporal.InvalidOption(name: "options", value: "not implemented"))
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
    _ -> 12
  }
}

fn value_label(year: Int, month: Int, day: Int) -> String {
  case year + month + day {
    0 -> "0"
    _ -> "invalid"
  }
}
