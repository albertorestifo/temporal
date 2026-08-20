//// Local time-zone discovery from the host's current UTC offset.
////
//// Temporal's `SystemTimeZoneIdentifier` prefers a primary IANA identifier and
//// falls back to an offset. Without a versioned IANA provider only the offset
//// is observable here, so discovery reports the fixed offset the host is using
//// at the moment of the read; it can change across a daylight-saving
//// transition.

import gleam/int
import gleam/result
import temporal
import temporal/internal/now_clock
import temporal/time_zone

/// Reads the host's current UTC offset as a validated time zone.
pub fn discover() -> Result(time_zone.TimeZone, temporal.Error) {
  from_offset_minutes(now_clock.local_offset_minutes())
}

/// Converts a host offset in minutes east of UTC to a validated time zone.
///
/// Returns `Error(PlatformUnavailable(LocalTimeZoneDiscovery))` when the host
/// reports an offset Temporal cannot represent, which must be under 24 hours.
///
/// ```gleam
/// now_local_zone.from_offset_minutes(-330)
/// // -> Ok(time_zone) with the identifier "-05:30"
/// ```
pub fn from_offset_minutes(
  total_minutes: Int,
) -> Result(time_zone.TimeZone, temporal.Error) {
  time_zone.from_offset(offset_identifier(total_minutes))
  |> result.replace_error(temporal.PlatformUnavailable(
    temporal.LocalTimeZoneDiscovery,
  ))
}

fn offset_identifier(total_minutes: Int) -> String {
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
