//// UTC and fixed-offset time-zone identifiers.
////
//// Named IANA zones require an explicit, versioned provider and are rejected
//// by this core implementation. They are not represented as a string payload
//// on the core type.

import gleam/int
import gleam/option.{type Option}
import gleam/string
import temporal
import temporal/instant
import temporal/plain_date_time

const nanoseconds_per_minute = 60_000_000_000

/// A validated time-zone kind.
///
/// Core values are `Utc` or a validated `FixedOffset`. Named IANA identifiers
/// are not a closed core set; `from_id` / `from_string` reject them with
/// `UnknownTimeZone` until a versioned provider exists.
pub opaque type TimeZone {
  Utc
  FixedOffset(total_minutes: Int)
  Named(id: String)
}

/// Return the canonical UTC time zone.
pub fn utc() -> TimeZone {
  Utc
}

/// Build a named-zone fixture for package tests.
///
/// Production callers must use `from_id` or `from_string`.
@internal
pub fn named_fixture(id: String) -> TimeZone {
  Named(id)
}

/// Parse a supported time-zone identifier from its spec string.
///
/// `UTC` is matched case-insensitively. Numeric offsets must use `+HH:MM` or
/// `-HH:MM`. Named IANA identifiers return `UnknownTimeZone` until a provider
/// is configured.
pub fn from_string(id: String) -> Result(TimeZone, temporal.Error) {
  case string.lowercase(id) {
    "utc" -> Ok(utc())
    _ ->
      case from_offset(id) {
        Ok(time_zone) -> Ok(time_zone)
        Error(_) -> Error(temporal.UnknownTimeZone(id))
      }
  }
}

/// Parse a supported time-zone identifier.
///
/// This is the identifier-named form of `from_string`.
pub fn from_id(id: String) -> Result(TimeZone, temporal.Error) {
  from_string(id)
}

/// Parse and canonicalize a fixed numeric offset.
///
/// Accepted offsets use `+HH:MM` or `-HH:MM`, with an absolute value less
/// than 24 hours. Negative zero is canonicalized to `+00:00`.
pub fn from_offset(offset: String) -> Result(TimeZone, temporal.Error) {
  case string.to_graphemes(offset) {
    [sign, hour_tens, hour_ones, ":", minute_tens, minute_ones] ->
      parse_offset_parts(
        offset,
        sign,
        hour_tens <> hour_ones,
        minute_tens <> minute_ones,
      )
    _ -> Error(temporal.InvalidIsoString(offset))
  }
}

/// Return the canonical time-zone identifier.
pub fn to_string(time_zone: TimeZone) -> String {
  case time_zone {
    Utc -> "UTC"
    FixedOffset(total_minutes) -> format_offset_minutes(total_minutes)
    Named(id) -> id
  }
}

/// Return the canonical time-zone identifier.
///
/// This is the identifier-named form of `to_string`.
pub fn id(time_zone: TimeZone) -> String {
  to_string(time_zone)
}

/// Return whether two time-zone variants are equal.
pub fn equal(first: TimeZone, second: TimeZone) -> Bool {
  first == second
}

/// Return the zone's UTC offset, in nanoseconds, for an instant.
///
/// Fixed offsets do not vary by instant.
pub fn offset_nanoseconds_for(
  time_zone: TimeZone,
  _instant: instant.Instant,
) -> Result(Int, temporal.Error) {
  case time_zone {
    Utc -> Ok(0)
    FixedOffset(total_minutes) -> Ok(total_minutes * nanoseconds_per_minute)
    Named(_) -> unavailable()
  }
}

/// Return the zone's canonical ISO 8601 UTC offset for an instant.
///
/// Fixed offsets do not vary by instant.
pub fn offset_iso_8601_for(
  time_zone: TimeZone,
  _instant: instant.Instant,
) -> Result(String, temporal.Error) {
  case time_zone {
    Utc -> Ok("+00:00")
    FixedOffset(total_minutes) -> Ok(format_offset_minutes(total_minutes))
    Named(_) -> unavailable()
  }
}

/// Return the first named-zone transition after an instant.
pub fn next_transition(
  _time_zone: TimeZone,
  _instant: instant.Instant,
) -> Result(Option(instant.Instant), temporal.Error) {
  unavailable()
}

/// Return the first named-zone transition before an instant.
pub fn previous_transition(
  _time_zone: TimeZone,
  _instant: instant.Instant,
) -> Result(Option(instant.Instant), temporal.Error) {
  unavailable()
}

/// Return possible instants for a local time in a named zone.
pub fn possible_instants_for(
  _time_zone: TimeZone,
  _date_time: plain_date_time.PlainDateTime,
) -> Result(List(instant.Instant), temporal.Error) {
  unavailable()
}

fn parse_offset_parts(
  input: String,
  sign: String,
  hour_text: String,
  minute_text: String,
) -> Result(TimeZone, temporal.Error) {
  case sign, int.parse(hour_text), int.parse(minute_text) {
    "+", Ok(hours), Ok(minutes) -> build_offset(input, False, hours, minutes)
    "-", Ok(hours), Ok(minutes) -> build_offset(input, True, hours, minutes)
    _, _, _ -> Error(temporal.InvalidIsoString(input))
  }
}

fn build_offset(
  input: String,
  negative: Bool,
  hours: Int,
  minutes: Int,
) -> Result(TimeZone, temporal.Error) {
  case hours < 24 && minutes < 60 {
    False -> Error(temporal.InvalidIsoString(input))
    True -> {
      let magnitude = hours * 60 + minutes
      let total_minutes = case negative && magnitude != 0 {
        True -> -magnitude
        False -> magnitude
      }
      Ok(FixedOffset(total_minutes))
    }
  }
}

fn format_offset_minutes(total_minutes: Int) -> String {
  let sign = case total_minutes < 0 {
    True -> "-"
    False -> "+"
  }
  let magnitude = int.absolute_value(total_minutes)
  sign <> two_digits(magnitude / 60) <> ":" <> two_digits(magnitude % 60)
}

fn two_digits(value: Int) -> String {
  case value < 10 {
    True -> "0" <> int.to_string(value)
    False -> int.to_string(value)
  }
}

fn unavailable() -> Result(a, temporal.Error) {
  Error(temporal.PlatformUnavailable(temporal.NamedTimeZoneProvider))
}
