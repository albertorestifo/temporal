// The unit argument exists for `erlang:system_time/1`; `Date.now` is
// millisecond-only, so it is ignored here.
export function epochMilliseconds(_unit) {
  return Date.now();
}
