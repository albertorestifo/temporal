//// Exact instants paired with a time zone and calendar.
////
//// Construction from an existing instant is available for UTC and fixed
//// offsets. Local date-time conversion and calendar-aware arithmetic remain
//// compile-clean provider stubs until the PlainDateTime foundation lands.

import bigi
import gleam/option.{type Option}
import gleam/order.{type Order, Eq}
import temporal
import temporal/calendar
import temporal/duration
import temporal/instant
import temporal/plain_date_time
import temporal/plain_time
import temporal/time_zone

/// An exact instant viewed through a time zone and calendar.
pub opaque type ZonedDateTime {
  ZonedDateTime(
    instant: instant.Instant,
    time_zone: time_zone.TimeZone,
    calendar: calendar.Calendar,
  )
}

/// Optional local fields used by `with_fields`.
pub type PartialZonedDateTime {
  PartialZonedDateTime(
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
    offset: Option(String),
  )
}

/// Parse an annotated Temporal zoned date-time string.
///
/// Parsing is unavailable until local ISO date-time conversion is provided.
pub fn from_iso_8601(_value: String) -> Result(ZonedDateTime, temporal.Error) {
  Error(temporal.PlatformUnavailable(temporal.ZonedDateTimeFromIso8601))
}

/// Combine an exact instant with a validated time zone and calendar.
///
/// Instants outside Temporal's inclusive ±10^8-day range return `OutOfRange`.
pub fn from_instant(
  value: instant.Instant,
  time_zone time_zone_value: time_zone.TimeZone,
  calendar calendar_value: calendar.Calendar,
) -> Result(ZonedDateTime, temporal.Error) {
  case instant.from_epoch_nanoseconds_int(value) {
    Ok(valid) -> Ok(ZonedDateTime(valid, time_zone_value, calendar_value))
    Error(_) ->
      Error(temporal.OutOfRange(
        temporal.EpochNanoseconds,
        bigi.to_string(value),
      ))
  }
}

/// Resolve a local date-time in a validated time zone.
///
/// This remains unavailable until local time-zone resolution is implemented.
pub fn from_plain_date_time(
  _date_time: plain_date_time.PlainDateTime,
  _time_zone: time_zone.TimeZone,
  _disambiguation: temporal.Disambiguation,
) -> Result(ZonedDateTime, temporal.Error) {
  Error(temporal.PlatformUnavailable(temporal.ZonedDateTimeFromPlainDateTime))
}

/// Return the exact instant represented by a zoned date-time.
pub fn to_instant(value: ZonedDateTime) -> instant.Instant {
  value.instant
}

/// Return the local ISO date-time represented in this value's time zone.
pub fn to_plain_date_time(
  _value: ZonedDateTime,
) -> Result(plain_date_time.PlainDateTime, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local calendar year.
pub fn year(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local calendar month.
pub fn month(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local calendar month code.
pub fn month_code(_value: ZonedDateTime) -> Result(String, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local calendar day.
pub fn day(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local hour.
pub fn hour(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local minute.
pub fn minute(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local second.
pub fn second(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local millisecond.
pub fn millisecond(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local microsecond.
pub fn microsecond(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local nanosecond.
pub fn nanosecond(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the calendar-specific era, or `None` for ISO 8601.
pub fn era(
  _value: ZonedDateTime,
) -> Result(Option(calendar.Era), temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the calendar-specific era year, or `None` for ISO 8601.
pub fn era_year(_value: ZonedDateTime) -> Result(Option(Int), temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local ISO day of week.
pub fn day_of_week(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local ISO day of year.
pub fn day_of_year(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local ISO week number.
pub fn week_of_year(
  _value: ZonedDateTime,
) -> Result(Option(Int), temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the local ISO week-numbering year.
pub fn year_of_week(
  _value: ZonedDateTime,
) -> Result(Option(Int), temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return seven for the ISO calendar.
pub fn days_in_week(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the number of days in the local month.
pub fn days_in_month(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return the number of days in the local year.
pub fn days_in_year(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return twelve for the ISO calendar.
pub fn months_in_year(_value: ZonedDateTime) -> Result(Int, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Report whether the local ISO year is a leap year.
pub fn in_leap_year(_value: ZonedDateTime) -> Result(Bool, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToPlainDateTime)
}

/// Return whole epoch milliseconds, flooring negative sub-milliseconds.
pub fn epoch_milliseconds(value: ZonedDateTime) -> Int {
  instant.epoch_milliseconds(value.instant)
}

/// Return exact epoch nanoseconds.
pub fn epoch_nanoseconds(value: ZonedDateTime) -> bigi.BigInt {
  value.instant
}

/// Return the time zone attached to this value.
pub fn time_zone(value: ZonedDateTime) -> time_zone.TimeZone {
  value.time_zone
}

/// Return the calendar attached to this value.
pub fn calendar(value: ZonedDateTime) -> calendar.Calendar {
  value.calendar
}

/// Return the UTC offset in nanoseconds at this instant.
pub fn offset_nanoseconds(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  time_zone.offset_nanoseconds_for(value.time_zone, value.instant)
}

/// Return the ISO 8601 UTC offset at this instant.
pub fn offset(value: ZonedDateTime) -> Result(String, temporal.Error) {
  time_zone.offset_iso_8601_for(value.time_zone, value.instant)
}

/// Compare two values by exact instant.
pub fn compare(first: ZonedDateTime, second: ZonedDateTime) -> Order {
  instant.compare(first.instant, second.instant)
}

/// Return whether exact instant, time zone, and calendar all match.
pub fn equal(first: ZonedDateTime, second: ZonedDateTime) -> Bool {
  instant.compare(first.instant, second.instant) == Eq
  && time_zone.equal(first.time_zone, second.time_zone)
  && calendar.equal(first.calendar, second.calendar)
}

/// Replace the supplied local fields.
pub fn with_fields(
  _value: ZonedDateTime,
  _fields: PartialZonedDateTime,
  _overflow: temporal.Overflow,
  _disambiguation: temporal.Disambiguation,
  _offset_behavior: temporal.OffsetBehavior,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.ZonedDateTimeFromPlainDateTime)
}

/// Replace the local time, using midnight when absent.
pub fn with_plain_time(
  _value: ZonedDateTime,
  _time: Option(plain_time.PlainTime),
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.ZonedDateTimeFromPlainDateTime)
}

/// View the same exact instant in another time zone.
pub fn with_time_zone(
  _value: ZonedDateTime,
  _time_zone: time_zone.TimeZone,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.NamedTimeZoneProvider)
}

/// Replace the calendar while retaining the exact instant and time zone.
pub fn with_calendar(
  _value: ZonedDateTime,
  _calendar: calendar.Calendar,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.NonIsoCalendarProvider)
}

/// Return the adjacent named-zone transition in a direction.
pub fn get_time_zone_transition(
  _value: ZonedDateTime,
  _direction: temporal.Direction,
) -> Result(Option(ZonedDateTime), temporal.Error) {
  unavailable(temporal.NamedTimeZoneProvider)
}

/// Add a duration using zoned, calendar-aware arithmetic.
///
/// This operation is unavailable until local date-time conversion is
/// implemented.
pub fn add(
  _value: ZonedDateTime,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.ZonedDateTimeAdd)
}

/// Subtract a duration using zoned, calendar-aware arithmetic.
///
/// This operation is unavailable until local date-time conversion is
/// implemented.
pub fn subtract(
  _value: ZonedDateTime,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.ZonedDateTimeSubtract)
}

/// Return the elapsed duration until another zoned date-time.
pub fn until(
  _first: ZonedDateTime,
  _second: ZonedDateTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  unavailable(temporal.ZonedDateTimeDifference)
}

/// Return the elapsed duration since another zoned date-time.
pub fn since(
  _first: ZonedDateTime,
  _second: ZonedDateTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  unavailable(temporal.ZonedDateTimeDifference)
}

/// Round a zoned date-time to an increment of a unit.
pub fn round(
  _value: ZonedDateTime,
  _smallest_unit: duration.Unit,
  _rounding_increment: Int,
  _rounding_mode: temporal.RoundingMode,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.ZonedDateTimeRound)
}

/// Return the start of the local calendar day.
///
/// This operation is unavailable until local date-time conversion is
/// implemented.
pub fn start_of_day(
  _value: ZonedDateTime,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable(temporal.ZonedDateTimeStartOfDay)
}

/// Return the length of the local day in hours.
///
/// This operation is unavailable until named-zone transition data is
/// provided.
pub fn hours_in_day(_value: ZonedDateTime) -> Result(Float, temporal.Error) {
  unavailable(temporal.ZonedDateTimeHoursInDay)
}

/// Serialize a zoned date-time in annotated ISO 8601 form.
///
/// This operation is unavailable until local date-time conversion is
/// implemented.
pub fn to_iso_8601(_value: ZonedDateTime) -> Result(String, temporal.Error) {
  unavailable(temporal.ZonedDateTimeToIso8601)
}

fn unavailable(
  operation: temporal.PlatformOperation,
) -> Result(a, temporal.Error) {
  Error(temporal.PlatformUnavailable(operation))
}
