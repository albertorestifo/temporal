import bigi
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

pub fn from_epoch_milliseconds(milliseconds: Int) -> Result(Instant, Nil) {
  milliseconds
  |> bigi.from_int()
  |> bigi.power(10, 6)
  |> result.map_ok(Instant)
}
