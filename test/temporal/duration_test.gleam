import temporal/duration.{type Duration, Duration, from_iso_8601}
import temporal/support/assertions

fn duration(
  is_negative: Bool,
  years: Int,
  months: Int,
  weeks: Int,
  days: Int,
  hours: Int,
  minutes: Int,
  seconds: Int,
  milliseconds: Int,
  microseconds: Int,
  nanoseconds: Int,
) -> Duration {
  Duration(
    is_negative: is_negative,
    years: years,
    months: months,
    weeks: weeks,
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
    microseconds: microseconds,
    nanoseconds: nanoseconds,
  )
}

fn assert_parses(input: String, expected: Duration) {
  assertions.equal_with_context(input, from_iso_8601(input), Ok(expected))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_weeks_and_days_test() {
  assert_parses("P3W1D", duration(False, 0, 0, 3, 1, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_negative_years_and_months_test() {
  assert_parses("-P1Y1M", duration(True, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_explicit_positive_sign_test() {
  assert_parses("+P1Y1M", duration(False, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_fractional_seconds_test() {
  assert_parses(
    "P1Y1M1DT1H1M1.1S",
    duration(False, 1, 1, 0, 1, 1, 1, 1, 100, 0, 0),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_preserves_unbalanced_days_test() {
  assert_parses("P40D", duration(False, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_years_and_days_test() {
  assert_parses("P1Y1D", duration(False, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_days_hours_and_minutes_test() {
  assert_parses("P3DT4H59M", duration(False, 0, 0, 0, 3, 4, 59, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_hours_and_minutes_test() {
  assert_parses("PT2H30M", duration(False, 0, 0, 0, 0, 2, 30, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_months_test() {
  assert_parses("P1M", duration(False, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_fractional_subseconds_test() {
  assert_parses("PT0.0021S", duration(False, 0, 0, 0, 0, 0, 0, 0, 2, 100, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/blank-duration.js
pub fn duration_from_parses_zero_seconds_test() {
  assert_parses("PT0S", duration(False, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/blank-duration.js
pub fn duration_from_parses_zero_days_test() {
  assert_parses("P0D", duration(False, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_fractional_hour_near_one_test() {
  assert_parses(
    "PT0.999999999H",
    duration(False, 0, 0, 0, 0, 0, 59, 59, 999, 996, 400),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_small_fractional_hour_test() {
  assert_parses(
    "PT0.000000011H",
    duration(False, 0, 0, 0, 0, 0, 0, 0, 0, 39, 600),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_fractional_minute_near_one_test() {
  assert_parses(
    "PT0.999999999M",
    duration(False, 0, 0, 0, 0, 0, 0, 59, 999, 999, 940),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_small_fractional_minute_test() {
  assert_parses(
    "PT0.000000011M",
    duration(False, 0, 0, 0, 0, 0, 0, 0, 0, 0, 660),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_fractional_second_near_one_test() {
  assert_parses(
    "PT0.999999999S",
    duration(False, 0, 0, 0, 0, 0, 0, 0, 999, 999, 999),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_small_fractional_second_test() {
  assert_parses(
    "PT0.000000011S",
    duration(False, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11),
  )
}
