//// ISO 8601 date-times without a time zone.

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/string
import temporal
import temporal/calendar
import temporal/duration
import temporal/internal/iso_plain as iso
import temporal/plain_date
import temporal/plain_time

/// A validated ISO date and wall-clock time.
pub opaque type PlainDateTime {
  PlainDateTime(date: plain_date.PlainDate, time: plain_time.PlainTime)
}

/// Optional date-time fields used by `with_fields`.
pub type PartialDateTime {
  PartialDateTime(
    year: Option(Int),
    month: Option(Int),
    month_code: Option(String),
    day: Option(Int),
    hour: Option(Int),
    minute: Option(Int),
    second: Option(Int),
    millisecond: Option(Int),
    microsecond: Option(Int),
    nanosecond: Option(Int),
  )
}

/// Builds an unvalidated date-time fixture for package tests.
@internal
pub fn fixture(
  date date: plain_date.PlainDate,
  time time: plain_time.PlainTime,
) -> PlainDateTime {
  PlainDateTime(date: date, time: time)
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
  case string.split(value, "T") {
    [date_value, time_value] -> {
      use date <- result_try(plain_date.from_iso_8601(date_value))
      use time <- result_try(plain_time.from_iso_8601(time_value))
      Ok(PlainDateTime(date, time))
    }
    _ -> Error(temporal.InvalidIsoString(input: value))
  }
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

/// Returns the calendar of this date-time.
pub fn calendar(value: PlainDateTime) -> calendar.Calendar {
  plain_date.calendar(value.date)
}

/// Return the calendar-specific era, or `None` for ISO 8601.
pub fn era(value: PlainDateTime) -> Option(calendar.Era) {
  plain_date.era(value.date)
}

/// Return the calendar-specific era year, or `None` for ISO 8601.
pub fn era_year(value: PlainDateTime) -> Option(Int) {
  plain_date.era_year(value.date)
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
  case plain_date.compare(first.date, second.date) {
    order.Eq -> plain_time.compare(first.time, second.time)
    other -> other
  }
}

/// Reports whether two date-times and calendars are equal.
pub fn equal(first: PlainDateTime, second: PlainDateTime) -> Bool {
  first == second
}

/// Replace the supplied date-time fields.
pub fn with_fields(
  value: PlainDateTime,
  fields: PartialDateTime,
  overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error) {
  case has_any_fields(fields) {
    False -> Error(temporal.OutOfRange(temporal.Date, "no fields"))
    True -> {
      let date_fields =
        plain_date.PartialDate(
          year: fields.year,
          month: fields.month,
          month_code: fields.month_code,
          day: fields.day,
        )
      let time_fields =
        plain_time.PartialTime(
          hour: fields.hour,
          minute: fields.minute,
          second: fields.second,
          millisecond: fields.millisecond,
          microsecond: fields.microsecond,
          nanosecond: fields.nanosecond,
        )
      use date <- result_try(case plain_date.has_any_fields(date_fields) {
        True -> plain_date.with_fields(value.date, date_fields, overflow)
        False -> Ok(value.date)
      })
      use time <- result_try(case plain_time.has_any_fields(time_fields) {
        True -> plain_time.with_fields(value.time, time_fields, overflow)
        False -> Ok(value.time)
      })
      Ok(PlainDateTime(date, time))
    }
  }
}

/// Replace the time component, using midnight when absent.
pub fn with_plain_time(
  value: PlainDateTime,
  time: Option(plain_time.PlainTime),
) -> Result(PlainDateTime, temporal.Error) {
  case time {
    Some(time) -> Ok(PlainDateTime(value.date, time))
    None -> {
      use midnight <- result_try(plain_time.new(
        0,
        0,
        0,
        0,
        0,
        0,
        temporal.Reject,
      ))
      Ok(PlainDateTime(value.date, midnight))
    }
  }
}

/// Replace the calendar while retaining the ISO date-time.
pub fn with_calendar(
  value: PlainDateTime,
  calendar_value: calendar.Calendar,
) -> Result(PlainDateTime, temporal.Error) {
  use date <- result_try(plain_date.with_calendar(value.date, calendar_value))
  Ok(PlainDateTime(date, value.time))
}

/// Adds a duration.
pub fn add(
  value: PlainDateTime,
  amount: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error) {
  use _ <- result_try(validate_duration(amount))
  let sign = case amount.is_negative {
    True -> -1
    False -> 1
  }
  let subday_nanoseconds =
    amount.hours
    * 3_600_000_000_000
    + amount.minutes
    * 60_000_000_000
    + amount.seconds
    * 1_000_000_000
    + amount.milliseconds
    * 1_000_000
    + amount.microseconds
    * 1000
    + amount.nanoseconds
  let time_nanoseconds =
    plain_time_nanoseconds(value.time) + sign * subday_nanoseconds
  let #(day_carry, balanced_time) = iso.nanoseconds_to_time(time_nanoseconds)
  let date_amount =
    duration.Duration(
      is_negative: amount.is_negative,
      years: amount.years,
      months: amount.months,
      weeks: amount.weeks,
      days: amount.days,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    )
  use date <- result_try(plain_date.add(value.date, date_amount, overflow))
  let carry =
    duration.Duration(
      is_negative: day_carry < 0,
      years: 0,
      months: 0,
      weeks: 0,
      days: absolute(day_carry),
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    )
  use final_date <- result_try(plain_date.add(date, carry, overflow))
  let iso.Time(h, m, s, ms, us, ns) = balanced_time
  use final_time <- result_try(plain_time.new(
    h,
    m,
    s,
    ms,
    us,
    ns,
    temporal.Reject,
  ))
  Ok(PlainDateTime(final_date, final_time))
}

/// Subtracts a duration.
pub fn subtract(
  value: PlainDateTime,
  amount: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error) {
  add(
    value,
    duration.Duration(..amount, is_negative: !amount.is_negative),
    overflow,
  )
}

/// Returns the elapsed duration until another date-time.
pub fn until(
  first: PlainDateTime,
  second: PlainDateTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  let day_difference =
    iso.days_between(internal_date(first.date), internal_date(second.date))
  duration_from_nanoseconds(
    day_difference
    * 86_400_000_000_000
    + plain_time_nanoseconds(second.time)
    - plain_time_nanoseconds(first.time),
  )
  |> Ok
}

/// Returns the elapsed duration since another date-time.
pub fn since(
  first: PlainDateTime,
  second: PlainDateTime,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  until(second, first, options)
}

/// Rounds a date-time.
pub fn round(
  value: PlainDateTime,
  smallest_unit: duration.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(PlainDateTime, temporal.Error) {
  use time <- result_try(plain_time.round(
    value.time,
    smallest_unit,
    rounding_increment,
    rounding_mode,
  ))
  Ok(PlainDateTime(value.date, time))
}

/// Serializes a date-time using ISO 8601.
pub fn to_iso_8601(value: PlainDateTime) -> String {
  plain_date.to_iso_8601(value.date)
  <> "T"
  <> plain_time.to_iso_8601(value.time)
}

/// Serializes a date-time using explicit formatting options.
pub fn to_iso_8601_with_options(
  value: PlainDateTime,
  _options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  Ok(to_iso_8601(value))
}

/// Report whether a typed partial date-time contains at least one field.
pub fn has_any_fields(fields: PartialDateTime) -> Bool {
  fields.year != None
  || fields.month != None
  || fields.month_code != None
  || fields.day != None
  || fields.hour != None
  || fields.minute != None
  || fields.second != None
  || fields.millisecond != None
  || fields.microsecond != None
  || fields.nanosecond != None
}

fn internal_date(date: plain_date.PlainDate) -> iso.Date {
  iso.Date(plain_date.year(date), plain_date.month(date), plain_date.day(date))
}

fn plain_time_nanoseconds(time: plain_time.PlainTime) -> Int {
  iso.time_to_nanoseconds(iso.Time(
    plain_time.hour(time),
    plain_time.minute(time),
    plain_time.second(time),
    plain_time.millisecond(time),
    plain_time.microsecond(time),
    plain_time.nanosecond(time),
  ))
}

fn validate_duration(value: duration.Duration) -> Result(Nil, temporal.Error) {
  case
    value.years >= 0
    && value.months >= 0
    && value.weeks >= 0
    && value.days >= 0
    && value.hours >= 0
    && value.minutes >= 0
    && value.seconds >= 0
    && value.milliseconds >= 0
    && value.microseconds >= 0
    && value.nanoseconds >= 0
  {
    True -> Ok(Nil)
    False -> Error(temporal.InvalidDuration("negative duration field"))
  }
}

fn duration_from_nanoseconds(value: Int) -> duration.Duration {
  let magnitude = absolute(value)
  let days = magnitude / 86_400_000_000_000
  let after_days = modulo(magnitude, 86_400_000_000_000)
  let hours = after_days / 3_600_000_000_000
  let after_hours = modulo(after_days, 3_600_000_000_000)
  let minutes = after_hours / 60_000_000_000
  let after_minutes = modulo(after_hours, 60_000_000_000)
  let seconds = after_minutes / 1_000_000_000
  let after_seconds = modulo(after_minutes, 1_000_000_000)
  let milliseconds = after_seconds / 1_000_000
  let after_milliseconds = modulo(after_seconds, 1_000_000)
  let microseconds = after_milliseconds / 1000
  duration.Duration(
    is_negative: value < 0,
    years: 0,
    months: 0,
    weeks: 0,
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
    microseconds: microseconds,
    nanoseconds: modulo(after_milliseconds, 1000),
  )
}

fn absolute(value: Int) -> Int {
  case value < 0 {
    True -> value * -1
    False -> value
  }
}

fn modulo(value: Int, divisor: Int) -> Int {
  let assert Ok(result) = int.modulo(value, divisor)
  result
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
