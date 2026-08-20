//// Shared ISO-calendar fixtures for Plain type conformance tests.

import gleam/option.{None}
import temporal
import temporal/calendar
import temporal/duration

/// Returns the built-in ISO 8601 calendar.
pub fn iso_calendar() -> calendar.Calendar {
  calendar.Iso8601
}

/// Returns typed difference options used by core tests.
pub fn difference_options() -> duration.DifferenceOptions {
  duration.DifferenceOptions(
    largest_unit: duration.Day,
    smallest_unit: duration.Nanosecond,
    rounding_increment: 1,
    rounding_mode: temporal.HalfExpand,
  )
}

/// Returns typed ISO serialization options used by core tests.
pub fn to_string_options() -> duration.ToStringOptions {
  duration.ToStringOptions(
    precision: duration.AutoPrecision,
    smallest_unit: None,
    rounding_mode: temporal.Trunc,
    calendar_name: duration.Auto,
    time_zone_name: duration.Auto,
    offset: duration.Auto,
  )
}

/// Returns a one-day duration using the public labeled record literal.
pub fn one_day() -> duration.Duration {
  duration.Duration(
    is_negative: False,
    years: 0,
    months: 0,
    weeks: 0,
    days: 1,
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
}
