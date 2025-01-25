import bigi
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result

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
pub fn from_epoch_milliseconds(milliseconds: Int) -> Result(Instant, Nil) {
  let multiplier = bigi.from_int(1_000_000)

  milliseconds
  |> bigi.from_int()
  |> bigi.multiply(multiplier)
  |> is_valid_epoch_nanoseconds()
}

/// Creates an Instant from an epoch nanoseconds value, expressed a bigi.BigInt
///
/// You can convert an Int to a bigi.BigInt with `bigi.from_int`.
pub fn from_epoch_nanoseconds_int(
  nanoseconds: bigi.BigInt,
) -> Result(Instant, Nil) {
  nanoseconds
  |> is_valid_epoch_nanoseconds()
}

/// Compare two Instants. Returns the Order denoting in a is less than, equal to, or greater than b.
pub fn compare(a: Instant, b: Instant) -> Order {
  bigi.compare(a, b)
}

/// Converts an Instant to an epoch milliseconds value.
pub fn epoch_milliseconds(instant: Instant) -> Int {
  let multiplier = bigi.from_int(1_000_000)

  instant
  |> bigi.divide(multiplier)
  |> bigi.to_int()
  |> result.unwrap(0)
}

fn is_valid_epoch_nanoseconds(value: Instant) -> Result(Instant, Nil) {
  let max = max_epoch_nanoseconds()
  let min = bigi.multiply(max, bigi.from_int(-1))

  case bigi.compare(value, max) {
    Lt ->
      case bigi.compare(value, min) {
        Lt -> Error(Nil)
        Eq -> Ok(value)
        Gt -> Ok(value)
      }
    Eq -> Ok(value)
    Gt -> Error(Nil)
  }
}

const ms_per_day = 86_400_000

fn max_epoch_nanoseconds() -> Instant {
  let ns_per_day =
    bigi.multiply(bigi.from_int(ms_per_day), bigi.from_int(1_000_000))
  bigi.multiply(ns_per_day, bigi.from_int(1_000_000_000))
}
