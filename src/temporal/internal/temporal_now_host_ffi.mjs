export function epochMilliseconds() {
  return Date.now();
}

export function localOffsetMinutes() {
  // getTimezoneOffset reports the minutes to add to local time to reach UTC,
  // which is the opposite sign of a Temporal offset. Zero is returned directly
  // to avoid negating it into -0.
  const minutesToUtc = new Date().getTimezoneOffset();
  return minutesToUtc === 0 ? 0 : -minutesToUtc;
}
