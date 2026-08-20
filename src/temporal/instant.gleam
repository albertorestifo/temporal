//// Exact, time-zone-independent points on the UTC timeline.

import bigi
import gleam/option.{None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import temporal
import temporal/duration
import temporal/internal/instant_iso as iso

/// An Instant is a single point in time (called "exact time"), with a precision in nanoseconds.
/// No time zone or calendar information is present.
/// To obtain local date/time units like year, month, day, or hour, a temporal.Instant must be combined with
/// a time zone identifier.
///
/// temporal.Instant stores an integer count of nanoseconds since the Unix epoch of January 1, 1970 at 00:00 UTC,
/// ignoring leap seconds.
///
/// A temporal.Instant can also be created from an ISO 8601 / RFC 3339 string like
/// '2020-01-23T17:04:36.491865121-08:00' or '2020-01-24T01:04Z'.
///
/// Like Unix time, temporal.Instant ignores leap seconds.
pub type Instant =
  bigi.BigInt

/// Creates an Instant from an epoch milliseconds value.
///
/// Returns `Error(OutOfRange(EpochMilliseconds, ...))` when the value falls
/// outside Temporal's inclusive ±10^8-day range.
pub fn from_epoch_milliseconds(
  milliseconds: Int,
) -> Result(Instant, temporal.Error) {
  bigi.from_int(milliseconds)
  |> bigi.multiply(bigi.from_int(nanoseconds_per_millisecond))
  |> validate(temporal.EpochMilliseconds)
}

/// Creates an Instant from an epoch nanoseconds value, expressed a bigi.BigInt
///
/// You can convert an Int to a bigi.BigInt with `bigi.from_int`.
pub fn from_epoch_nanoseconds_int(
  nanoseconds: bigi.BigInt,
) -> Result(Instant, temporal.Error) {
  validate(nanoseconds, temporal.EpochNanoseconds)
}

/// Creates an Instant from epoch nanoseconds.
///
/// Returns `Error(OutOfRange(EpochNanoseconds, ...))` when the value falls
/// outside Temporal's inclusive ±10^8-day range.
pub fn from_epoch_nanoseconds(
  nanoseconds: bigi.BigInt,
) -> Result(Instant, temporal.Error) {
  from_epoch_nanoseconds_int(nanoseconds)
}

/// Parses an ISO 8601 instant containing a UTC offset.
///
/// The string must carry a complete calendar date, a wall-clock time, and
/// either `Z` or a numeric UTC offset. A trailing time-zone annotation is
/// accepted and ignored.
///
/// Returns `Error(InvalidIsoString(...))` for malformed input and
/// `Error(OutOfRange(EpochNanoseconds, ...))` for instants outside Temporal's
/// range.
///
/// ```gleam
/// let assert Ok(epoch) = instant.from_iso_8601("1970-01-01T00:00:00Z")
/// ```
pub fn from_iso_8601(value: String) -> Result(Instant, temporal.Error) {
  case iso.parse(value) {
    Ok(nanoseconds) -> validate(nanoseconds, temporal.EpochNanoseconds)
    Error(Nil) -> Error(temporal.InvalidIsoString(input: value))
  }
}

/// Compare two Instants. Returns the Order denoting in a is less than, equal to, or greater than b.
pub fn compare(a: Instant, b: Instant) -> Order {
  bigi.compare(a, b)
}

/// Reports whether two instants have equal epoch nanoseconds.
pub fn equal(first: Instant, second: Instant) -> Bool {
  compare(first, second) == Eq
}

/// Returns the exact epoch nanoseconds.
pub fn epoch_nanoseconds(instant: Instant) -> bigi.BigInt {
  instant
}

/// Adds a time-only duration to an instant.
///
/// Days count as 24 hours; years, months, and weeks have no meaning without a
/// calendar and return `Error(InvalidDuration(...))`.
pub fn add(
  instant: Instant,
  duration: duration.Duration,
) -> Result(Instant, temporal.Error) {
  use nanoseconds <- result.try(time_duration_nanoseconds(duration))
  validate(bigi.add(instant, nanoseconds), temporal.EpochNanoseconds)
}

/// Subtracts a time-only duration from an instant.
///
/// Days count as 24 hours; years, months, and weeks have no meaning without a
/// calendar and return `Error(InvalidDuration(...))`.
pub fn subtract(
  instant: Instant,
  duration: duration.Duration,
) -> Result(Instant, temporal.Error) {
  use nanoseconds <- result.try(time_duration_nanoseconds(duration))
  validate(bigi.subtract(instant, nanoseconds), temporal.EpochNanoseconds)
}

/// Returns the duration from the first instant until the second.
///
/// `largest_unit` and `smallest_unit` accept days and smaller units, where a
/// day is 24 hours. Calendar units return
/// `Error(InvalidOption(DifferenceOptions))`.
pub fn until(
  first: Instant,
  second: Instant,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  use largest <- result.try(difference_unit_nanoseconds(options.largest_unit))
  use smallest <- result.try(difference_unit_nanoseconds(options.smallest_unit))
  use _ <- result.try(check_rounding_increment(options.rounding_increment))
  case smallest <= largest {
    False -> Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
    True ->
      bigi.subtract(second, first)
      |> round_to_increment(
        increment_nanoseconds(smallest, options.rounding_increment),
        options.rounding_mode,
      )
      |> balance(largest)
  }
}

/// Returns the duration since the second instant.
///
/// `largest_unit` and `smallest_unit` accept days and smaller units, where a
/// day is 24 hours. Calendar units return
/// `Error(InvalidOption(DifferenceOptions))`.
pub fn since(
  first: Instant,
  second: Instant,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  until(second, first, options)
}

/// Rounds an instant to an increment of the requested unit.
///
/// `smallest_unit` accepts hours and smaller units. Larger units return
/// `Error(InvalidOption(RoundingIncrementOption))`, as does a rounding
/// increment below one.
pub fn round(
  instant: Instant,
  smallest_unit: duration.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(Instant, temporal.Error) {
  use unit <- result.try(rounding_unit_nanoseconds(smallest_unit))
  use _ <- result.try(check_rounding_increment(rounding_increment))
  instant
  |> round_to_increment(
    increment_nanoseconds(unit, rounding_increment),
    rounding_mode,
  )
  |> validate(temporal.EpochNanoseconds)
}

/// Serializes an instant in UTC using ISO 8601.
///
/// The fractional part carries three, six, or nine digits, and is omitted when
/// the instant lands on a whole second.
///
/// ```gleam
/// instant.to_iso_8601(epoch)
/// // -> "1970-01-01T00:00:00Z"
/// ```
pub fn to_iso_8601(instant: Instant) -> String {
  iso.format(instant, iso.AutoFraction)
}

/// Serializes an instant using explicit formatting options.
///
/// `smallest_unit` takes precedence over `precision` and rounds the serialized
/// value with `rounding_mode`. The calendar, time-zone, and offset displays do
/// not apply to an instant, which always serializes in UTC.
pub fn to_iso_8601_with_options(
  instant: Instant,
  options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  use fraction <- result.try(serialized_fraction(options))
  use rounded <- result.try(round_for_serialization(instant, options))
  Ok(iso.format(rounded, fraction))
}

/// Converts an Instant to an epoch milliseconds value.
///
/// Sub-millisecond digits are floored towards negative infinity, so an instant
/// before the epoch reports the millisecond that contains it.
pub fn epoch_milliseconds(instant: Instant) -> Int {
  let divisor = bigi.from_int(nanoseconds_per_millisecond)
  let quotient = bigi.divide(instant, divisor)
  let floored = case
    bigi.compare(bigi.remainder(instant, divisor), bigi.zero())
  {
    Lt -> bigi.subtract(quotient, bigi.from_int(1))
    _ -> quotient
  }
  case bigi.to_int(floored) {
    Ok(milliseconds) -> milliseconds
    Error(Nil) -> 0
  }
}

const nanoseconds_per_millisecond = 1_000_000

const nanoseconds_per_day = 86_400_000_000_000

const nanoseconds_per_hour = 3_600_000_000_000

const nanoseconds_per_minute = 60_000_000_000

const nanoseconds_per_second = 1_000_000_000

const nanoseconds_per_microsecond = 1000

/// How a magnitude moves when the signed rounding mode is applied to it.
type UnsignedRounding {
  TowardsZero
  AwayFromZero
  HalfTowardsZero
  HalfAwayFromZero
  HalfToEven
}

fn validate(
  value: bigi.BigInt,
  field: temporal.Field,
) -> Result(Instant, temporal.Error) {
  case iso.is_valid_epoch_nanoseconds(value) {
    True -> Ok(value)
    False -> Error(temporal.OutOfRange(field, bigi.to_string(value)))
  }
}

fn time_duration_nanoseconds(
  value: duration.Duration,
) -> Result(bigi.BigInt, temporal.Error) {
  case value.years != 0 || value.months != 0 || value.weeks != 0 {
    True ->
      Error(temporal.InvalidDuration(
        reason: "instant arithmetic accepts 24-hour days and time units only",
      ))
    False ->
      case has_negative_field(value) {
        True ->
          Error(temporal.InvalidDuration(
            reason: "duration fields are non-negative magnitudes",
          ))
        False -> {
          let magnitude =
            bigi.sum([
              scale(value.days, nanoseconds_per_day),
              scale(value.hours, nanoseconds_per_hour),
              scale(value.minutes, nanoseconds_per_minute),
              scale(value.seconds, nanoseconds_per_second),
              scale(value.milliseconds, nanoseconds_per_millisecond),
              scale(value.microseconds, nanoseconds_per_microsecond),
              bigi.from_int(value.nanoseconds),
            ])
          case value.is_negative {
            True -> Ok(bigi.negate(magnitude))
            False -> Ok(magnitude)
          }
        }
      }
  }
}

fn has_negative_field(value: duration.Duration) -> Bool {
  value.days < 0
  || value.hours < 0
  || value.minutes < 0
  || value.seconds < 0
  || value.milliseconds < 0
  || value.microseconds < 0
  || value.nanoseconds < 0
}

fn scale(value: Int, factor: Int) -> bigi.BigInt {
  bigi.multiply(bigi.from_int(value), bigi.from_int(factor))
}

fn difference_unit_nanoseconds(
  unit: duration.Unit,
) -> Result(Int, temporal.Error) {
  case unit {
    duration.Day -> Ok(nanoseconds_per_day)
    duration.Hour -> Ok(nanoseconds_per_hour)
    duration.Minute -> Ok(nanoseconds_per_minute)
    duration.Second -> Ok(nanoseconds_per_second)
    duration.Millisecond -> Ok(nanoseconds_per_millisecond)
    duration.Microsecond -> Ok(nanoseconds_per_microsecond)
    duration.Nanosecond -> Ok(1)
    _ -> Error(temporal.InvalidOption(option: temporal.DifferenceOptions))
  }
}

fn rounding_unit_nanoseconds(unit: duration.Unit) -> Result(Int, temporal.Error) {
  case unit {
    duration.Hour -> Ok(nanoseconds_per_hour)
    duration.Minute -> Ok(nanoseconds_per_minute)
    duration.Second -> Ok(nanoseconds_per_second)
    duration.Millisecond -> Ok(nanoseconds_per_millisecond)
    duration.Microsecond -> Ok(nanoseconds_per_microsecond)
    duration.Nanosecond -> Ok(1)
    _ -> Error(temporal.InvalidOption(option: temporal.RoundingIncrementOption))
  }
}

fn check_rounding_increment(increment: Int) -> Result(Nil, temporal.Error) {
  case increment > 0 {
    True -> Ok(Nil)
    False ->
      Error(temporal.InvalidOption(option: temporal.RoundingIncrementOption))
  }
}

fn increment_nanoseconds(unit: Int, increment: Int) -> bigi.BigInt {
  bigi.multiply(bigi.from_int(unit), bigi.from_int(increment))
}

fn balance(
  total: bigi.BigInt,
  largest: Int,
) -> Result(duration.Duration, temporal.Error) {
  let negative = bigi.compare(total, bigi.zero()) == Lt
  let #(days, rest) =
    take_unit(bigi.absolute(total), nanoseconds_per_day, largest)
  let #(hours, rest) = take_unit(rest, nanoseconds_per_hour, largest)
  let #(minutes, rest) = take_unit(rest, nanoseconds_per_minute, largest)
  let #(seconds, rest) = take_unit(rest, nanoseconds_per_second, largest)
  let #(milliseconds, rest) =
    take_unit(rest, nanoseconds_per_millisecond, largest)
  let #(microseconds, rest) =
    take_unit(rest, nanoseconds_per_microsecond, largest)
  use days <- result.try(component(days))
  use hours <- result.try(component(hours))
  use minutes <- result.try(component(minutes))
  use seconds <- result.try(component(seconds))
  use milliseconds <- result.try(component(milliseconds))
  use microseconds <- result.try(component(microseconds))
  use nanoseconds <- result.try(component(rest))
  Ok(duration.Duration(
    is_negative: negative,
    years: 0,
    months: 0,
    weeks: 0,
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
    microseconds: microseconds,
    nanoseconds: nanoseconds,
  ))
}

fn take_unit(
  value: bigi.BigInt,
  unit: Int,
  largest: Int,
) -> #(bigi.BigInt, bigi.BigInt) {
  case unit <= largest {
    False -> #(bigi.zero(), value)
    True -> {
      let divisor = bigi.from_int(unit)
      #(bigi.divide(value, divisor), bigi.remainder(value, divisor))
    }
  }
}

fn component(value: bigi.BigInt) -> Result(Int, temporal.Error) {
  case bigi.to_int(value) {
    Ok(component) -> Ok(component)
    Error(Nil) ->
      Error(temporal.OutOfRange(
        temporal.EpochNanoseconds,
        bigi.to_string(value),
      ))
  }
}

fn round_to_increment(
  value: bigi.BigInt,
  increment: bigi.BigInt,
  mode: temporal.RoundingMode,
) -> bigi.BigInt {
  let negative = bigi.compare(value, bigi.zero()) == Lt
  let magnitude = bigi.absolute(value)
  let lower = bigi.multiply(bigi.divide(magnitude, increment), increment)
  let doubled_remainder =
    bigi.multiply(bigi.subtract(magnitude, lower), bigi.from_int(2))
  let higher = bigi.add(lower, increment)
  let rounded = case unsigned_rounding(mode, negative) {
    TowardsZero -> lower
    AwayFromZero ->
      case bigi.compare(doubled_remainder, bigi.zero()) {
        Eq -> lower
        _ -> higher
      }
    HalfTowardsZero ->
      case bigi.compare(doubled_remainder, increment) {
        Gt -> higher
        _ -> lower
      }
    HalfAwayFromZero ->
      case bigi.compare(doubled_remainder, increment) {
        Lt -> lower
        _ -> higher
      }
    HalfToEven ->
      case bigi.compare(doubled_remainder, increment) {
        Lt -> lower
        Gt -> higher
        Eq ->
          case bigi.is_odd(bigi.divide(lower, increment)) {
            True -> higher
            False -> lower
          }
      }
  }
  case negative {
    True -> bigi.negate(rounded)
    False -> rounded
  }
}

fn unsigned_rounding(
  mode: temporal.RoundingMode,
  negative: Bool,
) -> UnsignedRounding {
  case mode, negative {
    temporal.Ceil, True -> TowardsZero
    temporal.Ceil, False -> AwayFromZero
    temporal.Floor, True -> AwayFromZero
    temporal.Floor, False -> TowardsZero
    temporal.Trunc, _ -> TowardsZero
    temporal.Expand, _ -> AwayFromZero
    temporal.HalfCeil, True -> HalfTowardsZero
    temporal.HalfCeil, False -> HalfAwayFromZero
    temporal.HalfFloor, True -> HalfAwayFromZero
    temporal.HalfFloor, False -> HalfTowardsZero
    temporal.HalfTrunc, _ -> HalfTowardsZero
    temporal.HalfExpand, _ -> HalfAwayFromZero
    temporal.HalfEven, _ -> HalfToEven
  }
}

fn serialized_fraction(
  options: duration.ToStringOptions,
) -> Result(iso.Fraction, temporal.Error) {
  case options.smallest_unit {
    Some(duration.Minute) -> Ok(iso.MinuteFraction)
    Some(duration.Second) -> Ok(iso.FixedFraction(digits: 0))
    Some(duration.Millisecond) -> Ok(iso.FixedFraction(digits: 3))
    Some(duration.Microsecond) -> Ok(iso.FixedFraction(digits: 6))
    Some(duration.Nanosecond) -> Ok(iso.FixedFraction(digits: 9))
    Some(_) -> Error(temporal.InvalidOption(option: temporal.ToStringOptions))
    None ->
      case options.precision {
        duration.AutoPrecision -> Ok(iso.AutoFraction)
        duration.Digits(digits) ->
          case digits >= 0 && digits <= 9 {
            True -> Ok(iso.FixedFraction(digits: digits))
            False ->
              Error(temporal.InvalidOption(option: temporal.ToStringOptions))
          }
      }
  }
}

fn round_for_serialization(
  instant: Instant,
  options: duration.ToStringOptions,
) -> Result(Instant, temporal.Error) {
  case options.smallest_unit {
    Some(unit) -> round(instant, unit, 1, options.rounding_mode)
    None ->
      case options.precision {
        duration.AutoPrecision -> Ok(instant)
        duration.Digits(digits) ->
          instant
          |> round_to_increment(
            bigi.from_int(digit_nanoseconds(digits)),
            options.rounding_mode,
          )
          |> validate(temporal.EpochNanoseconds)
      }
  }
}

fn digit_nanoseconds(digits: Int) -> Int {
  case digits {
    0 -> nanoseconds_per_second
    1 -> 100_000_000
    2 -> 10_000_000
    3 -> nanoseconds_per_millisecond
    4 -> 100_000
    5 -> 10_000
    6 -> nanoseconds_per_microsecond
    7 -> 100
    8 -> 10
    _ -> 1
  }
}
