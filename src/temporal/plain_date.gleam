//// ISO 8601 calendar dates without a time or time zone.

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import temporal
import temporal/calendar
import temporal/duration
import temporal/internal/iso_plain as iso
import temporal/plain_month_day
import temporal/plain_year_month

/// A validated ISO calendar date.
pub opaque type PlainDate {
  PlainDate(year: Int, month: Int, day: Int, calendar: calendar.Calendar)
}

/// Optional date fields used by `with_fields`.
pub type PartialDate {
  PartialDate(
    year: Option(Int),
    month: Option(Int),
    month_code: Option(String),
    day: Option(Int),
  )
}

/// Builds an unvalidated date fixture for package tests.
@internal
pub fn fixture(year year: Int, month month: Int, day day: Int) -> PlainDate {
  PlainDate(year: year, month: month, day: day, calendar: calendar.Iso8601)
}

/// Constructs an ISO calendar date.
///
/// Calendar is temporarily the identifier `iso8601` until the calendar module
/// lands.
pub fn new(
  year year: Int,
  month month: Int,
  day day: Int,
  calendar calendar_value: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  case calendar_value {
    calendar.Iso8601 -> {
      use value <- result_try(iso.regulate_date(year, month, day, overflow))
      let iso.Date(year, month, day) = value
      Ok(PlainDate(year, month, day, calendar_value))
    }
    _ -> Error(temporal.PlatformUnavailable(temporal.NonIsoCalendarProvider))
  }
}

/// Parses an ISO 8601 calendar date.
pub fn from_iso_8601(value: String) -> Result(PlainDate, temporal.Error) {
  use date <- result_try(iso.parse_date(value))
  let iso.Date(year, month, day) = date
  Ok(PlainDate(year, month, day, calendar.Iso8601))
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

/// Returns the calendar of this date.
pub fn calendar(date: PlainDate) -> calendar.Calendar {
  date.calendar
}

/// Return the calendar-specific era, or `None` for ISO 8601.
pub fn era(_date: PlainDate) -> Option(calendar.Era) {
  None
}

/// Return the calendar-specific era year, or `None` for ISO 8601.
pub fn era_year(_date: PlainDate) -> Option(Int) {
  None
}

/// Returns the ISO day of week from 1 through 7.
pub fn day_of_week(date: PlainDate) -> Int {
  iso.day_of_week(to_internal(date))
}

/// Returns the ISO day of year.
pub fn day_of_year(date: PlainDate) -> Int {
  iso.day_of_year(to_internal(date))
}

/// Returns the ISO week number.
pub fn week_of_year(date: PlainDate) -> Option(Int) {
  let #(_, week) = iso.iso_week(to_internal(date))
  Some(week)
}

/// Returns the ISO week-numbering year.
pub fn year_of_week(date: PlainDate) -> Option(Int) {
  let #(year, _) = iso.iso_week(to_internal(date))
  Some(year)
}

/// Returns seven for the ISO calendar.
pub fn days_in_week(_date: PlainDate) -> Int {
  7
}

/// Returns the number of days in the ISO month.
pub fn days_in_month(date: PlainDate) -> Int {
  iso.days_in_month(date.year, date.month)
}

/// Returns the number of days in the ISO year.
pub fn days_in_year(date: PlainDate) -> Int {
  case iso.is_leap_year(date.year) {
    True -> 366
    False -> 365
  }
}

/// Returns twelve for the ISO calendar.
pub fn months_in_year(_date: PlainDate) -> Int {
  12
}

/// Reports whether the ISO year is a leap year.
pub fn in_leap_year(date: PlainDate) -> Bool {
  iso.is_leap_year(date.year)
}

/// Compares two ISO dates.
pub fn compare(first: PlainDate, second: PlainDate) -> Order {
  case int.compare(first.year, second.year) {
    order.Eq ->
      case int.compare(first.month, second.month) {
        order.Eq -> int.compare(first.day, second.day)
        other -> other
      }
    other -> other
  }
}

/// Reports whether two dates and calendars are equal.
pub fn equal(first: PlainDate, second: PlainDate) -> Bool {
  first == second
}

/// Replace the supplied date fields.
pub fn with_fields(
  date: PlainDate,
  fields: PartialDate,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  case date.calendar {
    calendar.Iso8601 ->
      case has_any_fields(fields) {
        False -> Error(temporal.OutOfRange(temporal.Date, "no fields"))
        True -> {
          let year = option_or(fields.year, date.year)
          let month_result =
            resolve_month(fields.month, fields.month_code, date.month)
          use month <- result_try(month_result)
          new(
            year: year,
            month: month,
            day: option_or(fields.day, date.day),
            calendar: calendar.Iso8601,
            overflow: overflow,
          )
        }
      }
    _ -> Error(temporal.PlatformUnavailable(temporal.NonIsoCalendarProvider))
  }
}

/// Replace the calendar while retaining the ISO date.
pub fn with_calendar(
  date: PlainDate,
  calendar_value: calendar.Calendar,
) -> Result(PlainDate, temporal.Error) {
  Ok(PlainDate(..date, calendar: calendar_value))
}

/// Report whether a typed partial date contains at least one field.
pub fn has_any_fields(fields: PartialDate) -> Bool {
  fields.year != None
  || fields.month != None
  || fields.month_code != None
  || fields.day != None
}

/// Adds a duration to a date.
pub fn add(
  date: PlainDate,
  value: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  case date.calendar {
    calendar.Iso8601 -> {
      use _ <- result_try(validate_date_duration(value))
      let sign = duration_sign(value)
      use result <- result_try(iso.add_date(
        to_internal(date),
        value.years * sign,
        value.months * sign,
        value.weeks * sign,
        value.days * sign,
        overflow,
      ))
      Ok(from_internal(result))
    }
    _ -> Error(temporal.PlatformUnavailable(temporal.NonIsoCalendarProvider))
  }
}

/// Subtracts a duration from a date.
pub fn subtract(
  date: PlainDate,
  value: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error) {
  add(
    date,
    duration.Duration(..value, is_negative: !value.is_negative),
    overflow,
  )
}

/// Returns the elapsed duration until another date.
pub fn until(
  first: PlainDate,
  second: PlainDate,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Ok(
    duration_from_days(iso.days_between(to_internal(first), to_internal(second))),
  )
}

/// Returns the elapsed duration since another date.
pub fn since(
  first: PlainDate,
  second: PlainDate,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  until(second, first, options)
}

/// Serializes a date using ISO 8601.
pub fn to_iso_8601(date: PlainDate) -> String {
  iso.format_date(to_internal(date))
}

/// Serializes a date using explicit formatting options.
pub fn to_iso_8601_with_options(
  date: PlainDate,
  _options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  Ok(to_iso_8601(date))
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
  month_code: Option(String),
  fallback: Int,
) -> Result(Int, temporal.Error) {
  case month, month_code {
    None, None -> Ok(fallback)
    Some(value), None -> Ok(value)
    None, Some(code) ->
      case month_code_number(code) {
        0 -> Error(temporal.OutOfRange(temporal.Month, code))
        value -> Ok(value)
      }
    Some(value), Some(code) ->
      case month_code_number(code) == value {
        True -> Ok(value)
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

fn to_internal(date: PlainDate) -> iso.Date {
  iso.Date(date.year, date.month, date.day)
}

fn from_internal(date: iso.Date) -> PlainDate {
  let iso.Date(year, month, day) = date
  PlainDate(year, month, day, calendar.Iso8601)
}

fn duration_sign(value: duration.Duration) -> Int {
  case value.is_negative {
    True -> -1
    False -> 1
  }
}

fn validate_date_duration(
  value: duration.Duration,
) -> Result(Nil, temporal.Error) {
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
    False -> Error(temporal.InvalidDuration("invalid plain date duration"))
  }
}

fn duration_from_days(days: Int) -> duration.Duration {
  duration.Duration(
    is_negative: days < 0,
    years: 0,
    months: 0,
    weeks: 0,
    days: int.absolute_value(days),
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
