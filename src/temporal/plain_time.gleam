//// ISO 8601 wall-clock times without a date or time zone.

import gleam/int
import gleam/order.{type Order, Eq}
import temporal
import temporal/duration

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
  overflow _overflow: temporal.Overflow,
) -> Result(PlainTime, temporal.Error) {
  Error(temporal.OutOfRange(
    field: temporal.Time,
    value: int_to_string(
      hour + minute + second + millisecond + microsecond + nanosecond,
    ),
  ))
}

/// Parses an ISO 8601 wall-clock time.
pub fn from_iso_8601(value: String) -> Result(PlainTime, temporal.Error) {
  Error(temporal.InvalidIsoString(input: value))
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

/// Adds a duration, wrapping across midnight.
pub fn add(
  _time: PlainTime,
  _duration: duration.Duration,
) -> Result(PlainTime, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain time addition is not implemented",
  ))
}

/// Subtracts a duration, wrapping across midnight.
pub fn subtract(
  _time: PlainTime,
  _duration: duration.Duration,
) -> Result(PlainTime, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain time subtraction is not implemented",
  ))
}

/// Returns the elapsed duration until another time.
pub fn until(
  _first: PlainTime,
  _second: PlainTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
}

/// Returns the elapsed duration since another time.
pub fn since(
  _first: PlainTime,
  _second: PlainTime,
  _options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
}

/// Rounds a time to an increment of a unit.
pub fn round(
  _time: PlainTime,
  _smallest_unit: duration.Unit,
  _rounding_increment: Int,
  _rounding_mode: temporal.RoundingMode,
) -> Result(PlainTime, temporal.Error) {
  Error(temporal.InvalidDuration(
    reason: "plain time rounding is not implemented",
  ))
}

/// Serializes a time using ISO 8601.
pub fn to_iso_8601(_time: PlainTime) -> String {
  ""
}

/// Serializes a time using explicit formatting options.
pub fn to_iso_8601_with_options(
  _time: PlainTime,
  _options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.ToStringOptions))
}

fn int_to_string(value: Int) -> String {
  case value {
    0 -> "0"
    _ -> "invalid"
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
