//// UTC and fixed-offset time-zone identifiers.
////
//// Named IANA zones require an explicit, versioned provider, so parsing a
//// named identifier is rejected by this core implementation. A named zone
//// that is already represented resolves its offsets through the rule table in
//// `temporal/internal/named_zone`.

import bigi
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import temporal
import temporal/instant
import temporal/internal/named_zone
import temporal/plain_date_time

const nanoseconds_per_minute = 60_000_000_000

/// A validated time-zone kind.
///
/// Core values are `Utc` or a validated `FixedOffset`. A zero numeric offset
/// is `FixedOffset(0)` and keeps the identifier `+00:00`; it is a distinct
/// zone from `Utc`, so two zoned date-times that share an instant but differ
/// between `UTC` and `+00:00` are not equal. Named IANA identifiers are not a
/// closed core set; `from_id` / `from_string` reject them with
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
/// `UTC` and the UTC designator `Z` are matched case-insensitively and both
/// give `utc()`. Numeric offsets must use `+HH:MM` or `-HH:MM`, and `+00:00`
/// is the zero fixed offset rather than `utc()`. Named IANA identifiers return
/// `UnknownTimeZone` until a provider is configured.
pub fn from_string(id: String) -> Result(TimeZone, temporal.Error) {
  case string.lowercase(id) {
    "utc" | "z" -> Ok(utc())
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
/// than 24 hours. Both `+00:00` and `-00:00` give the zero fixed offset, which
/// is not `utc()`; parse `UTC` or `Z` with `from_string` for that.
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
/// Fixed offsets do not vary by instant. Named zones follow their rules and
/// return `PlatformUnavailable` when no rules are registered.
pub fn offset_nanoseconds_for(
  time_zone: TimeZone,
  at: instant.Instant,
) -> Result(Int, temporal.Error) {
  case time_zone {
    Utc -> Ok(0)
    FixedOffset(total_minutes) -> Ok(total_minutes * nanoseconds_per_minute)
    Named(id) -> {
      use zone <- result.try(named_rules(id))
      Ok(named_zone.offset_minutes_for(zone, at) * nanoseconds_per_minute)
    }
  }
}

/// Return the zone's canonical ISO 8601 UTC offset for an instant.
///
/// Fixed offsets do not vary by instant. Named zones follow their rules and
/// return `PlatformUnavailable` when no rules are registered.
pub fn offset_iso_8601_for(
  time_zone: TimeZone,
  at: instant.Instant,
) -> Result(String, temporal.Error) {
  case time_zone {
    Utc -> Ok("+00:00")
    FixedOffset(total_minutes) -> Ok(format_offset_minutes(total_minutes))
    Named(id) -> {
      use zone <- result.try(named_rules(id))
      Ok(format_offset_minutes(named_zone.offset_minutes_for(zone, at)))
    }
  }
}

/// Return the first named-zone transition after an instant.
///
/// UTC and fixed offsets never transition. `None` also reports a transition
/// that falls outside Temporal's representable instant range.
pub fn next_transition(
  time_zone: TimeZone,
  at: instant.Instant,
) -> Result(Option(instant.Instant), temporal.Error) {
  case time_zone {
    Utc | FixedOffset(_) -> Ok(None)
    Named(id) -> {
      use zone <- result.try(named_rules(id))
      Ok(representable(named_zone.next_transition(zone, at)))
    }
  }
}

/// Return the first named-zone transition before an instant.
///
/// UTC and fixed offsets never transition. `None` also reports a transition
/// that falls outside Temporal's representable instant range.
pub fn previous_transition(
  time_zone: TimeZone,
  at: instant.Instant,
) -> Result(Option(instant.Instant), temporal.Error) {
  case time_zone {
    Utc | FixedOffset(_) -> Ok(None)
    Named(id) -> {
      use zone <- result.try(named_rules(id))
      Ok(representable(named_zone.previous_transition(zone, at)))
    }
  }
}

/// Return possible instants for a local time in a zone.
///
/// The list is empty for a local time skipped by a forward transition and
/// holds two instants for one repeated by a backward transition.
pub fn possible_instants_for(
  time_zone: TimeZone,
  date_time: plain_date_time.PlainDateTime,
) -> Result(List(instant.Instant), temporal.Error) {
  case time_zone {
    Utc -> local_date_time_to_instant(date_time, 0)
    FixedOffset(total_minutes) ->
      local_date_time_to_instant(date_time, total_minutes)
    Named(id) -> {
      use zone <- result.try(named_rules(id))
      named_zone.possible_instants(zone, local_epoch_nanoseconds(date_time))
      |> list.try_map(to_instant)
    }
  }
}

fn named_rules(id: String) -> Result(named_zone.Zone, temporal.Error) {
  case named_zone.from_id(id) {
    Ok(zone) -> Ok(zone)
    Error(_) -> unavailable()
  }
}

fn representable(value: Option(bigi.BigInt)) -> Option(instant.Instant) {
  case value {
    None -> None
    Some(epoch_nanoseconds) ->
      option.from_result(instant.from_epoch_nanoseconds(epoch_nanoseconds))
  }
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

fn local_date_time_to_instant(
  date_time: plain_date_time.PlainDateTime,
  offset_minutes: Int,
) -> Result(List(instant.Instant), temporal.Error) {
  let epoch_nanoseconds =
    bigi.subtract(
      local_epoch_nanoseconds(date_time),
      bigi.from_int(offset_minutes * nanoseconds_per_minute),
    )
  use value <- result.try(to_instant(epoch_nanoseconds))
  Ok([value])
}

fn to_instant(
  epoch_nanoseconds: bigi.BigInt,
) -> Result(instant.Instant, temporal.Error) {
  case instant.from_epoch_nanoseconds(epoch_nanoseconds) {
    Ok(value) -> Ok(value)
    Error(_) ->
      Error(temporal.OutOfRange(
        field: temporal.EpochNanoseconds,
        value: bigi.to_string(epoch_nanoseconds),
      ))
  }
}

// Nanoseconds since the epoch for the local wall-clock fields, as if the
// local time were UTC.
fn local_epoch_nanoseconds(
  date_time: plain_date_time.PlainDateTime,
) -> bigi.BigInt {
  let epoch_days =
    days_from_civil(
      plain_date_time.year(date_time),
      plain_date_time.month(date_time),
      plain_date_time.day(date_time),
    )
  let time_nanoseconds =
    plain_date_time.hour(date_time)
    * 3_600_000_000_000
    + plain_date_time.minute(date_time)
    * 60_000_000_000
    + plain_date_time.second(date_time)
    * 1_000_000_000
    + plain_date_time.millisecond(date_time)
    * 1_000_000
    + plain_date_time.microsecond(date_time)
    * 1000
    + plain_date_time.nanosecond(date_time)

  epoch_days
  |> bigi.from_int()
  |> bigi.multiply(bigi.from_int(86_400_000_000_000))
  |> bigi.add(bigi.from_int(time_nanoseconds))
}

fn days_from_civil(year: Int, month: Int, day: Int) -> Int {
  let adjusted_year = case month <= 2 {
    True -> year - 1
    False -> year
  }
  let era_numerator = case adjusted_year >= 0 {
    True -> adjusted_year
    False -> adjusted_year - 399
  }
  let era = era_numerator / 400
  let year_of_era = adjusted_year - era * 400
  let shifted_month = case month > 2 {
    True -> month - 3
    False -> month + 9
  }
  let day_of_year = { 153 * shifted_month + 2 } / 5 + day - 1
  let day_of_era =
    year_of_era * 365 + year_of_era / 4 - year_of_era / 100 + day_of_year
  era * 146_097 + day_of_era - 719_468
}

fn unavailable() -> Result(a, temporal.Error) {
  Error(temporal.PlatformUnavailable(temporal.NamedTimeZoneProvider))
}
