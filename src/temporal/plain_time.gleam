//// ISO 8601 wall-clock times without a date or time zone.

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq}
import temporal
import temporal/duration
import temporal/internal/iso_plain as iso

/// A validated ISO wall-clock time.
pub opaque type PlainTime {
  PlainTime(
    hour: Int,
    minute: Int,
    second: Int,
    millisecond: Int,
    microsecond: Int,
    nanosecond: Int,
  )
}

/// Optional time fields used by `with_fields`.
pub type PartialTime {
  PartialTime(
    hour: Option(Int),
    minute: Option(Int),
    second: Option(Int),
    millisecond: Option(Int),
    microsecond: Option(Int),
    nanosecond: Option(Int),
  )
}

/// Builds an unvalidated time fixture for package tests.
@internal
pub fn fixture(
  hour hour: Int,
  minute minute: Int,
  second second: Int,
  millisecond millisecond: Int,
  microsecond microsecond: Int,
  nanosecond nanosecond: Int,
) -> PlainTime {
  PlainTime(
    hour: hour,
    minute: minute,
    second: second,
    millisecond: millisecond,
    microsecond: microsecond,
    nanosecond: nanosecond,
  )
}

/// Constructs an ISO wall-clock time.
pub fn new(
  hour hour: Int,
  minute minute: Int,
  second second: Int,
  millisecond millisecond: Int,
  microsecond microsecond: Int,
  nanosecond nanosecond: Int,
  overflow overflow: temporal.Overflow,
) -> Result(PlainTime, temporal.Error) {
  use value <- result_try(iso.regulate_time(
    hour,
    minute,
    second,
    millisecond,
    microsecond,
    nanosecond,
    overflow,
  ))
  Ok(from_internal(value))
}

/// Parses an ISO 8601 wall-clock time.
pub fn from_iso_8601(value: String) -> Result(PlainTime, temporal.Error) {
  use time <- result_try(iso.parse_time(value))
  Ok(from_internal(time))
}

/// Returns the hour.
pub fn hour(time: PlainTime) -> Int {
  let PlainTime(value, _, _, _, _, _) = time
  value
}

/// Returns the minute.
pub fn minute(time: PlainTime) -> Int {
  let PlainTime(_, value, _, _, _, _) = time
  value
}

/// Returns the second.
pub fn second(time: PlainTime) -> Int {
  let PlainTime(_, _, value, _, _, _) = time
  value
}

/// Returns the millisecond.
pub fn millisecond(time: PlainTime) -> Int {
  let PlainTime(_, _, _, value, _, _) = time
  value
}

/// Returns the microsecond.
pub fn microsecond(time: PlainTime) -> Int {
  let PlainTime(_, _, _, _, value, _) = time
  value
}

/// Returns the nanosecond.
pub fn nanosecond(time: PlainTime) -> Int {
  let PlainTime(_, _, _, _, _, value) = time
  value
}

/// Compares two times lexicographically.
pub fn compare(first: PlainTime, second: PlainTime) -> Order {
  let PlainTime(fh, fm, fs, fms, fus, fns) = first
  let PlainTime(sh, sm, ss, sms, sus, sns) = second
  compare_fields([fh, fm, fs, fms, fus, fns], [sh, sm, ss, sms, sus, sns])
}

/// Reports whether two times have equal fields.
pub fn equal(first: PlainTime, second: PlainTime) -> Bool {
  compare(first, second) == Eq
}

/// Replace the supplied wall-clock fields.
pub fn with_fields(
  time: PlainTime,
  fields: PartialTime,
  overflow: temporal.Overflow,
) -> Result(PlainTime, temporal.Error) {
  case has_any_fields(fields) {
    False -> Error(temporal.OutOfRange(temporal.Time, "no fields"))
    True ->
      new(
        hour: option_or(fields.hour, hour(time)),
        minute: option_or(fields.minute, minute(time)),
        second: option_or(fields.second, second(time)),
        millisecond: option_or(fields.millisecond, millisecond(time)),
        microsecond: option_or(fields.microsecond, microsecond(time)),
        nanosecond: option_or(fields.nanosecond, nanosecond(time)),
        overflow: overflow,
      )
  }
}

/// Adds a duration, wrapping across midnight.
pub fn add(
  time: PlainTime,
  value: duration.Duration,
) -> Result(PlainTime, temporal.Error) {
  use delta <- result_try(duration_nanoseconds(value))
  let #(_, result) =
    iso.nanoseconds_to_time(iso.time_to_nanoseconds(to_internal(time)) + delta)
  Ok(from_internal(result))
}

/// Subtracts a duration, wrapping across midnight.
pub fn subtract(
  time: PlainTime,
  value: duration.Duration,
) -> Result(PlainTime, temporal.Error) {
  add(time, duration.Duration(..value, is_negative: !value.is_negative))
}

/// Returns the elapsed duration until another time.
pub fn until(
  first: PlainTime,
  second: PlainTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Ok(duration_from_nanoseconds(
    iso.time_to_nanoseconds(to_internal(second))
    - iso.time_to_nanoseconds(to_internal(first)),
  ))
}

/// Returns the elapsed duration since another time.
pub fn since(
  first: PlainTime,
  second: PlainTime,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  until(second, first, options)
}

/// Rounds a time to an increment of a unit.
pub fn round(
  time: PlainTime,
  smallest_unit: duration.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(PlainTime, temporal.Error) {
  use unit <- result_try(unit_nanoseconds(smallest_unit))
  case rounding_increment > 0 {
    False -> Error(temporal.InvalidOption(temporal.RoundingIncrementOption))
    True -> {
      let rounded =
        round_positive(
          iso.time_to_nanoseconds(to_internal(time)),
          unit * rounding_increment,
          rounding_mode,
        )
      let #(_, result) = iso.nanoseconds_to_time(rounded)
      Ok(from_internal(result))
    }
  }
}

/// Serializes a time using ISO 8601.
pub fn to_iso_8601(time: PlainTime) -> String {
  iso.format_time(to_internal(time))
}

/// Serializes a time using explicit formatting options.
pub fn to_iso_8601_with_options(
  time: PlainTime,
  _options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  Ok(to_iso_8601(time))
}

/// Report whether a typed partial time contains at least one field.
pub fn has_any_fields(fields: PartialTime) -> Bool {
  fields.hour != None
  || fields.minute != None
  || fields.second != None
  || fields.millisecond != None
  || fields.microsecond != None
  || fields.nanosecond != None
}

fn option_or(value: Option(a), fallback: a) -> a {
  case value {
    Some(value) -> value
    None -> fallback
  }
}

fn compare_fields(first: List(Int), second: List(Int)) -> Order {
  case first, second {
    [], [] -> Eq
    [a, ..arest], [b, ..brest] ->
      case int.compare(a, b) {
        Eq -> compare_fields(arest, brest)
        other -> other
      }
    _, _ -> Eq
  }
}

fn to_internal(time: PlainTime) -> iso.Time {
  iso.Time(
    hour(time),
    minute(time),
    second(time),
    millisecond(time),
    microsecond(time),
    nanosecond(time),
  )
}

fn from_internal(time: iso.Time) -> PlainTime {
  let iso.Time(hour, minute, second, millisecond, microsecond, nanosecond) =
    time
  PlainTime(hour, minute, second, millisecond, microsecond, nanosecond)
}

fn duration_nanoseconds(value: duration.Duration) -> Result(Int, temporal.Error) {
  case
    value.years == 0
    && value.months == 0
    && value.weeks == 0
    && value.days >= 0
    && value.hours >= 0
    && value.minutes >= 0
    && value.seconds >= 0
    && value.milliseconds >= 0
    && value.microseconds >= 0
    && value.nanoseconds >= 0
  {
    False -> Error(temporal.InvalidDuration("invalid plain time duration"))
    True -> {
      let magnitude =
        value.days
        * 86_400_000_000_000
        + value.hours
        * 3_600_000_000_000
        + value.minutes
        * 60_000_000_000
        + value.seconds
        * 1_000_000_000
        + value.milliseconds
        * 1_000_000
        + value.microseconds
        * 1000
        + value.nanoseconds
      case value.is_negative {
        True -> Ok(magnitude * -1)
        False -> Ok(magnitude)
      }
    }
  }
}

fn duration_from_nanoseconds(value: Int) -> duration.Duration {
  let magnitude = int.absolute_value(value)
  let hours = magnitude / 3_600_000_000_000
  let after_hours = modulo(magnitude, 3_600_000_000_000)
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
    days: 0,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
    microseconds: microseconds,
    nanoseconds: modulo(after_milliseconds, 1000),
  )
}

fn unit_nanoseconds(unit: duration.Unit) -> Result(Int, temporal.Error) {
  case unit {
    duration.Hour -> Ok(3_600_000_000_000)
    duration.Minute -> Ok(60_000_000_000)
    duration.Second -> Ok(1_000_000_000)
    duration.Millisecond -> Ok(1_000_000)
    duration.Microsecond -> Ok(1000)
    duration.Nanosecond -> Ok(1)
    _ -> Error(temporal.InvalidOption(temporal.RoundingIncrementOption))
  }
}

fn round_positive(
  value: Int,
  increment: Int,
  mode: temporal.RoundingMode,
) -> Int {
  let lower = value / increment * increment
  let remainder = value - lower
  case mode {
    temporal.Ceil | temporal.Expand ->
      case remainder == 0 {
        True -> lower
        False -> lower + increment
      }
    temporal.Floor | temporal.Trunc -> lower
    _ ->
      case remainder * 2 >= increment {
        True -> lower + increment
        False -> lower
      }
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
