//// Rule-based offsets and transitions for a small set of named time zones.
////
//// These are POSIX-style daylight-saving rules, not the IANA time-zone
//// database: one rule covers the whole timeline, so instants from before a
//// rule was adopted are not historically accurate. Public identifier parsing
//// still requires a versioned provider, so `time_zone.from_string` keeps
//// rejecting named identifiers; these rules exist so that transition and
//// disambiguation behaviour can be exercised end to end.

import bigi
import gleam/list
import gleam/option.{type Option}
import gleam/order
import temporal/internal/iso_plain

const nanoseconds_per_day = 86_400_000_000_000

const nanoseconds_per_hour = 3_600_000_000_000

const nanoseconds_per_minute = 60_000_000_000

/// A daylight-saving rule shared by a group of named zones.
pub type Rule {
  /// Daylight saving from the last Sunday in March at 01:00 UTC until the
  /// last Sunday in October at 01:00 UTC.
  EuropeanUnion
}

/// The standard offset, daylight offset, and rule of one named zone.
pub opaque type Zone {
  Zone(standard_minutes: Int, daylight_minutes: Int, rule: Rule)
}

/// Look up the rules registered for a named time-zone identifier.
///
/// Identifiers outside this table have no rules and need a versioned
/// provider.
pub fn from_id(id: String) -> Result(Zone, Nil) {
  case id {
    "Europe/Amsterdam"
    | "Europe/Berlin"
    | "Europe/Brussels"
    | "Europe/Madrid"
    | "Europe/Paris"
    | "Europe/Rome"
    | "Europe/Vienna" -> Ok(Zone(60, 120, EuropeanUnion))
    _ -> Error(Nil)
  }
}

/// Return the zone's offset from UTC, in minutes, at an exact instant.
pub fn offset_minutes_for(zone: Zone, epoch_nanoseconds: bigi.BigInt) -> Int {
  let #(start, end) = daylight_bounds(zone, year_of(epoch_nanoseconds))
  case
    bigi.compare(epoch_nanoseconds, start) != order.Lt
    && bigi.compare(epoch_nanoseconds, end) == order.Lt
  {
    True -> zone.daylight_minutes
    False -> zone.standard_minutes
  }
}

/// Return the first offset transition strictly after an instant.
pub fn next_transition(
  zone: Zone,
  epoch_nanoseconds: bigi.BigInt,
) -> Option(bigi.BigInt) {
  let year = year_of(epoch_nanoseconds)
  transitions(zone, [year, year + 1])
  |> list.find(fn(value) { bigi.compare(value, epoch_nanoseconds) == order.Gt })
  |> option.from_result()
}

/// Return the last offset transition strictly before an instant.
pub fn previous_transition(
  zone: Zone,
  epoch_nanoseconds: bigi.BigInt,
) -> Option(bigi.BigInt) {
  let year = year_of(epoch_nanoseconds)
  transitions(zone, [year - 1, year])
  |> list.reverse()
  |> list.find(fn(value) { bigi.compare(value, epoch_nanoseconds) == order.Lt })
  |> option.from_result()
}

/// Return the instants a local date-time maps to, in ascending order.
///
/// The list is empty inside a spring-forward gap and holds two instants
/// inside a fall-back overlap.
pub fn possible_instants(
  zone: Zone,
  local_epoch_nanoseconds: bigi.BigInt,
) -> List(bigi.BigInt) {
  candidate_offset_minutes(zone)
  |> list.filter_map(fn(offset_minutes) {
    let candidate =
      bigi.subtract(
        local_epoch_nanoseconds,
        bigi.from_int(offset_minutes * nanoseconds_per_minute),
      )
    case offset_minutes_for(zone, candidate) == offset_minutes {
      True -> Ok(candidate)
      False -> Error(Nil)
    }
  })
  |> list.sort(bigi.compare)
}

fn candidate_offset_minutes(zone: Zone) -> List(Int) {
  case zone.daylight_minutes == zone.standard_minutes {
    True -> [zone.standard_minutes]
    False -> [zone.standard_minutes, zone.daylight_minutes]
  }
}

fn transitions(zone: Zone, years: List(Int)) -> List(bigi.BigInt) {
  list.flat_map(years, fn(year) {
    let #(start, end) = daylight_bounds(zone, year)
    [start, end]
  })
}

fn daylight_bounds(zone: Zone, year: Int) -> #(bigi.BigInt, bigi.BigInt) {
  case zone.rule {
    EuropeanUnion -> #(
      last_sunday_at_01_utc(year, 3),
      last_sunday_at_01_utc(year, 10),
    )
  }
}

// March and October both end on the 31st, so the last Sunday is that day
// walked back by its ISO weekday, counting Sunday as zero.
fn last_sunday_at_01_utc(year: Int, month: Int) -> bigi.BigInt {
  let month_end = iso_plain.Date(year, month, 31)
  let sunday =
    iso_plain.add_days(month_end, -{ iso_plain.day_of_week(month_end) % 7 })
  bigi.from_int(epoch_day(sunday))
  |> bigi.multiply(bigi.from_int(nanoseconds_per_day))
  |> bigi.add(bigi.from_int(nanoseconds_per_hour))
}

fn epoch_day(date: iso_plain.Date) -> Int {
  iso_plain.days_between(iso_plain.Date(1970, 1, 1), date)
}

fn year_of(epoch_nanoseconds: bigi.BigInt) -> Int {
  let date =
    iso_plain.add_days(
      iso_plain.Date(1970, 1, 1),
      floor_days(epoch_nanoseconds),
    )
  date.year
}

fn floor_days(epoch_nanoseconds: bigi.BigInt) -> Int {
  let day = bigi.from_int(nanoseconds_per_day)
  let quotient = bigi.divide(epoch_nanoseconds, day)
  let remainder = bigi.subtract(epoch_nanoseconds, bigi.multiply(quotient, day))
  let days = case bigi.to_int(quotient) {
    Ok(value) -> value
    Error(_) -> 0
  }
  case bigi.compare(remainder, bigi.from_int(0)) == order.Lt {
    True -> days - 1
    False -> days
  }
}
