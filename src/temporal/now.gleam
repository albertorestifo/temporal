//// Access to the current instant through explicit clock values.
////
//// Use `fixed_clock` for deterministic computations and tests. The system
//// clock reads Unix epoch milliseconds on Erlang; targets without a clock
//// adapter return `PlatformUnavailable`.

import gleam/option.{type Option, None, Some}
import gleam/result
import temporal
import temporal/calendar
import temporal/instant
import temporal/time_zone
import temporal/zoned_date_time

type TimeUnit {
  Millisecond
}

// Calendars and zones are the variant types owned by `temporal/calendar` and
// `temporal/time_zone`; a clock never holds an unparsed identifier in their
// place.
/// A source of current-instant and time-zone data.
///
/// Clock values are immutable and do not replace process-global state.
pub opaque type Clock {
  SystemClock
  FixedClock(instant: instant.Instant, time_zone: time_zone.TimeZone)
}

/// Returns the platform system clock.
pub fn system_clock() -> Clock {
  SystemClock
}

/// Returns a deterministic clock fixed at `instant` and `time_zone`.
///
/// `time_zone` is an already validated `time_zone.TimeZone`; parse identifier
/// strings with `time_zone.from_id` or `time_zone.from_offset` first.
pub fn fixed_clock(
  instant instant: instant.Instant,
  time_zone time_zone_value: time_zone.TimeZone,
) -> Clock {
  FixedClock(instant, time_zone_value)
}

/// Reads the current instant from the system clock.
///
/// Returns `PlatformUnavailable` when the target has no system-clock adapter.
pub fn instant() -> Result(instant.Instant, temporal.Error) {
  instant_with_clock(system_clock())
}

/// Reads the current instant from `clock`.
pub fn instant_with_clock(
  clock: Clock,
) -> Result(instant.Instant, temporal.Error) {
  case clock {
    FixedClock(instant:, ..) -> Ok(instant)
    SystemClock -> {
      use milliseconds <- result.try(platform_epoch_milliseconds())
      instant.from_epoch_milliseconds(milliseconds)
      |> result.map_error(fn(_) {
        temporal.OutOfRange("epoch_milliseconds", "system clock")
      })
    }
  }
}

/// Reads the system clock's canonical time-zone identifier.
///
/// Local time-zone discovery is unavailable until target-specific adapters
/// are provided.
pub fn time_zone_id() -> Result(String, temporal.Error) {
  time_zone_id_with_clock(system_clock())
}

/// Reads the canonical time-zone identifier associated with `clock`.
///
/// The identifier is the serialized form of the clock's `TimeZone` value.
pub fn time_zone_id_with_clock(clock: Clock) -> Result(String, temporal.Error) {
  clock
  |> time_zone_with_clock()
  |> result.map(time_zone.id)
}

/// Reads the current instant as a zoned date-time in the ISO 8601 calendar.
///
/// Passing `None` uses the clock's own zone.
pub fn zoned_date_time_iso(
  time_zone zone_option: Option(time_zone.TimeZone),
) -> Result(zoned_date_time.ZonedDateTime, temporal.Error) {
  zoned_date_time_iso_with_clock(system_clock(), time_zone: zone_option)
}

/// Reads `clock` as a zoned date-time in the ISO 8601 calendar.
pub fn zoned_date_time_iso_with_clock(
  clock: Clock,
  time_zone zone_option: Option(time_zone.TimeZone),
) -> Result(zoned_date_time.ZonedDateTime, temporal.Error) {
  let zone_result = case zone_option {
    Some(zone) -> Ok(zone)
    None -> time_zone_with_clock(clock)
  }
  use zone <- result.try(zone_result)
  use current <- result.try(instant_with_clock(clock))
  zoned_date_time.from_instant(
    current,
    time_zone: zone,
    calendar: calendar.iso_8601(),
  )
}

fn time_zone_with_clock(
  clock: Clock,
) -> Result(time_zone.TimeZone, temporal.Error) {
  case clock {
    FixedClock(time_zone: zone, ..) -> Ok(zone)
    SystemClock ->
      Error(temporal.PlatformUnavailable("local time-zone discovery"))
  }
}

fn platform_epoch_milliseconds() -> Result(Int, temporal.Error) {
  case erlang_system_time(Millisecond) {
    // The fallback body is used on targets without an adapter.
    0 -> Error(temporal.PlatformUnavailable("system clock"))
    milliseconds -> Ok(milliseconds)
  }
}

@external(erlang, "erlang", "system_time")
fn erlang_system_time(_unit: TimeUnit) -> Int {
  0
}
