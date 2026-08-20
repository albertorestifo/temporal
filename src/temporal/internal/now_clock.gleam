//// Host clock and local time-zone reads behind one typed adapter.
////
//// Both targets expose the same two reads through a shim module named
//// `temporal_now_host_ffi`: Erlang over `erlang` and `calendar`, JavaScript
//// over `Date`.

/// Reads the host clock as milliseconds since the Unix epoch.
///
/// The value is negative for hosts set before 1970 and is not guaranteed to be
/// monotonic across reads.
@external(erlang, "temporal_now_host_ffi", "epoch_milliseconds")
@external(javascript, "./temporal_now_host_ffi.mjs", "epochMilliseconds")
pub fn epoch_milliseconds() -> Int

/// Reads the host's current offset from UTC, in minutes.
///
/// The offset is positive east of Greenwich. It reflects the daylight-saving
/// rule in effect at the moment of the read, so consecutive reads can differ.
@external(erlang, "temporal_now_host_ffi", "local_offset_minutes")
@external(javascript, "./temporal_now_host_ffi.mjs", "localOffsetMinutes")
pub fn local_offset_minutes() -> Int
