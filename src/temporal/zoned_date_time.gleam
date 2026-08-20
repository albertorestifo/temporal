//// Exact instants paired with a time zone and calendar.
////
//// Construction from an existing instant is available for UTC and fixed
//// offsets. Local date-time conversion and calendar-aware arithmetic remain
//// compile-clean provider stubs until the PlainDateTime foundation lands.

import bigi
import gleam/order.{type Order, Eq}
import temporal
import temporal/calendar
import temporal/duration
import temporal/instant
import temporal/time_zone

/// An exact instant viewed through a time zone and calendar.
pub opaque type ZonedDateTime {
  ZonedDateTime(
    instant: instant.Instant,
    time_zone: time_zone.TimeZone,
    calendar: calendar.Calendar,
  )
}

/// Parse an annotated Temporal zoned date-time string.
///
/// Parsing is unavailable until local ISO date-time conversion is provided.
pub fn from_iso_8601(value: String) -> Result(ZonedDateTime, temporal.Error) {
  Error(temporal.PlatformUnavailable("zoned_date_time.from_iso_8601:" <> value))
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
      Error(temporal.OutOfRange("epoch_nanoseconds", bigi.to_string(value)))
  }
}

/// Return the exact instant represented by a zoned date-time.
pub fn to_instant(value: ZonedDateTime) -> instant.Instant {
  value.instant
}

/// Return whole epoch milliseconds, flooring negative sub-milliseconds.
pub fn epoch_milliseconds(value: ZonedDateTime) -> Int {
  instant.epoch_milliseconds(value.instant)
}

/// Return exact epoch nanoseconds.
pub fn epoch_nanoseconds(value: ZonedDateTime) -> bigi.BigInt {
  value.instant
}

/// Return the canonical time-zone identifier.
pub fn time_zone_id(value: ZonedDateTime) -> String {
  time_zone.id(value.time_zone)
}

/// Return the canonical calendar identifier.
pub fn calendar_id(value: ZonedDateTime) -> String {
  calendar.id(value.calendar)
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

/// Add a duration using zoned, calendar-aware arithmetic.
///
/// This operation is unavailable until local date-time conversion is
/// implemented.
pub fn add(
  _value: ZonedDateTime,
  _duration: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable("zoned_date_time.add")
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
  unavailable("zoned_date_time.subtract")
}

/// Return the start of the local calendar day.
///
/// This operation is unavailable until local date-time conversion is
/// implemented.
pub fn start_of_day(
  _value: ZonedDateTime,
) -> Result(ZonedDateTime, temporal.Error) {
  unavailable("zoned_date_time.start_of_day")
}

/// Return the length of the local day in hours.
///
/// This operation is unavailable until named-zone transition data is
/// provided.
pub fn hours_in_day(_value: ZonedDateTime) -> Result(Float, temporal.Error) {
  unavailable("zoned_date_time.hours_in_day")
}

/// Serialize a zoned date-time in annotated ISO 8601 form.
///
/// This operation is unavailable until local date-time conversion is
/// implemented.
pub fn to_iso_8601(_value: ZonedDateTime) -> Result(String, temporal.Error) {
  unavailable("zoned_date_time.to_iso_8601")
}

fn unavailable(operation: String) -> Result(a, temporal.Error) {
  Error(temporal.PlatformUnavailable(operation))
}
