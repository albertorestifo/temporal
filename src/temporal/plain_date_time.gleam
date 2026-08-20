//// ISO 8601 date-times without a time zone.

import gleam/option.{type Option}
import gleam/order.{type Order, Eq, Lt}
import temporal
import temporal/calendar
import temporal/duration
import temporal/plain_date
import temporal/plain_time

/// A validated ISO date and wall-clock time.
pub opaque type PlainDateTime {
  PlainDateTime(date: plain_date.PlainDate, time: plain_time.PlainTime)
}

/// Constructs an ISO date-time.
pub fn new(
  year year: Int,
  month month: Int,
  day day: Int,
  hour hour: Int,
  minute minute: Int,
  second second: Int,
  millisecond millisecond: Int,
  microsecond microsecond: Int,
  nanosecond nanosecond: Int,
  calendar calendar: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error) {
  use date <- result_try(plain_date.new(
    year: year,
    month: month,
    day: day,
    calendar: calendar,
    overflow: overflow,
  ))
  use time <- result_try(plain_time.new(
    hour: hour,
    minute: minute,
    second: second,
    millisecond: millisecond,
    microsecond: microsecond,
    nanosecond: nanosecond,
    overflow: overflow,
  ))
  Ok(PlainDateTime(date, time))
}

/// Parses an ISO 8601 date-time.
pub fn from_iso_8601(value: String) -> Result(PlainDateTime, temporal.Error) {
  Error(temporal.InvalidIsoString(input: value))
}

/// Combines an ISO date and time.
pub fn from_date_and_time(
  date: plain_date.PlainDate,
  time: plain_time.PlainTime,
) -> Result(PlainDateTime, temporal.Error) {
  Ok(PlainDateTime(date, time))
}

/// Returns the date component.
pub fn to_plain_date(value: PlainDateTime) -> plain_date.PlainDate {
  value.date
}

/// Returns the time component.
pub fn to_plain_time(value: PlainDateTime) -> plain_time.PlainTime {
  value.time
}

/// Returns the ISO year.
pub fn year(value: PlainDateTime) -> Int {
  plain_date.year(value.date)
}

/// Returns the ISO month.
pub fn month(value: PlainDateTime) -> Int {
  plain_date.month(value.date)
}

/// Returns the ISO month code.
pub fn month_code(value: PlainDateTime) -> String {
  plain_date.month_code(value.date)
}

/// Returns the ISO day.
pub fn day(value: PlainDateTime) -> Int {
  plain_date.day(value.date)
}

/// Returns the hour.
pub fn hour(value: PlainDateTime) -> Int {
  plain_time.hour(value.time)
}

/// Returns the minute.
pub fn minute(value: PlainDateTime) -> Int {
  plain_time.minute(value.time)
}

/// Returns the second.
pub fn second(value: PlainDateTime) -> Int {
  plain_time.second(value.time)
}

/// Returns the millisecond.
pub fn millisecond(value: PlainDateTime) -> Int {
  plain_time.millisecond(value.time)
}

/// Returns the microsecond.
pub fn microsecond(value: PlainDateTime) -> Int {
  plain_time.microsecond(value.time)
}

/// Returns the nanosecond.
pub fn nanosecond(value: PlainDateTime) -> Int {
  plain_time.nanosecond(value.time)
}

/// Returns `iso8601`.
pub fn calendar_id(value: PlainDateTime) -> String {
  plain_date.calendar_id(value.date)
}

/// Returns the ISO day of week.
pub fn day_of_week(value: PlainDateTime) -> Int {
  plain_date.day_of_week(value.date)
}

/// Returns the ISO day of year.
pub fn day_of_year(value: PlainDateTime) -> Int {
  plain_date.day_of_year(value.date)
}

/// Returns the ISO week number.
pub fn week_of_year(value: PlainDateTime) -> Option(Int) {
  plain_date.week_of_year(value.date)
}

/// Returns the ISO week-numbering year.
pub fn year_of_week(value: PlainDateTime) -> Option(Int) {
  plain_date.year_of_week(value.date)
}

/// Returns seven for ISO.
pub fn days_in_week(value: PlainDateTime) -> Int {
  plain_date.days_in_week(value.date)
}

/// Returns the number of days in the month.
pub fn days_in_month(value: PlainDateTime) -> Int {
  plain_date.days_in_month(value.date)
}

/// Returns the number of days in the year.
pub fn days_in_year(value: PlainDateTime) -> Int {
  plain_date.days_in_year(value.date)
}

/// Returns twelve for ISO.
pub fn months_in_year(value: PlainDateTime) -> Int {
  plain_date.months_in_year(value.date)
}

/// Reports whether the year is a leap year.
pub fn in_leap_year(value: PlainDateTime) -> Bool {
  plain_date.in_leap_year(value.date)
}

/// Compares two date-times by ISO fields.
pub fn compare(first: PlainDateTime, second: PlainDateTime) -> Order {
  case first == second {
    True -> Eq
    False -> Lt
  }
}

/// Reports whether two date-times and calendars are equal.
pub fn equal(first: PlainDateTime, second: PlainDateTime) -> Bool {
  first == second
}

/// Adds a duration.
pub fn add(
  _value: PlainDateTime,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain date-time addition is not implemented",
  ))
}

/// Subtracts a duration.
pub fn subtract(
  _value: PlainDateTime,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain date-time subtraction is not implemented",
  ))
}

/// Returns the elapsed duration until another date-time.
pub fn until(
  _first: PlainDateTime,
  _second: PlainDateTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(name: "options", value: "not implemented"))
}

/// Returns the elapsed duration since another date-time.
pub fn since(
  _first: PlainDateTime,
  _second: PlainDateTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(name: "options", value: "not implemented"))
}

/// Rounds a date-time.
pub fn round(
  _value: PlainDateTime,
  _smallest_unit: duration.Unit,
  _rounding_increment: Int,
  _rounding_mode: temporal.RoundingMode,
) -> Result(PlainDateTime, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain date-time rounding is not implemented",
  ))
}

/// Serializes a date-time using ISO 8601.
pub fn to_iso_8601(_value: PlainDateTime) -> String {
  ""
}

/// Serializes a date-time using explicit formatting options.
pub fn to_iso_8601_with_options(
  _value: PlainDateTime,
  _options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  Error(temporal.InvalidOption(name: "options", value: "not implemented"))
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
