//// Host system-clock access behind one typed adapter.
////
//// Both supported targets read Unix epoch milliseconds: Erlang through
//// `erlang:system_time/1` and JavaScript through `Date.now`.

/// The resolution requested from the host clock.
///
/// Erlang takes the unit as an atom; the JavaScript adapter ignores it because
/// `Date.now` only reports milliseconds.
type TimeUnit {
  Millisecond
}

/// Reads the host clock as milliseconds since the Unix epoch.
///
/// The value is negative for hosts set before 1970 and is not guaranteed to be
/// monotonic across reads.
pub fn epoch_milliseconds() -> Int {
  platform_epoch_milliseconds(Millisecond)
}

@external(erlang, "erlang", "system_time")
@external(javascript, "./now_clock_ffi.mjs", "epochMilliseconds")
fn platform_epoch_milliseconds(unit: TimeUnit) -> Int
