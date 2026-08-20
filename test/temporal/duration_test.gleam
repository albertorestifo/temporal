import temporal/duration.{type Duration, Duration, from_iso_8601}
import temporal/support/assertions

fn assert_parses(input: String, expected: Duration) {
  assertions.equal_with_context(input, from_iso_8601(input), Ok(expected))
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_weeks_and_days_test() {
  assert_parses(
    "P3W1D",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 3,
      days: 1,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_negative_years_and_months_test() {
  assert_parses(
    "-P1Y1M",
    Duration(
      is_negative: True,
      years: 1,
      months: 1,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_explicit_positive_sign_test() {
  assert_parses(
    "+P1Y1M",
    Duration(
      is_negative: False,
      years: 1,
      months: 1,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_fractional_seconds_test() {
  assert_parses(
    "P1Y1M1DT1H1M1.1S",
    Duration(
      is_negative: False,
      years: 1,
      months: 1,
      weeks: 0,
      days: 1,
      hours: 1,
      minutes: 1,
      seconds: 1,
      milliseconds: 100,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_preserves_unbalanced_days_test() {
  assert_parses(
    "P40D",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 40,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_years_and_days_test() {
  assert_parses(
    "P1Y1D",
    Duration(
      is_negative: False,
      years: 1,
      months: 0,
      weeks: 0,
      days: 1,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_days_hours_and_minutes_test() {
  assert_parses(
    "P3DT4H59M",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 3,
      hours: 4,
      minutes: 59,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_hours_and_minutes_test() {
  assert_parses(
    "PT2H30M",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 2,
      minutes: 30,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn duration_from_parses_months_test() {
  assert_parses(
    "P1M",
    Duration(
      is_negative: False,
      years: 0,
      months: 1,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string.js
pub fn duration_from_parses_fractional_subseconds_test() {
  assert_parses(
    "PT0.0021S",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 2,
      microseconds: 100,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/blank-duration.js
pub fn duration_from_parses_zero_seconds_test() {
  assert_parses(
    "PT0S",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/blank-duration.js
pub fn duration_from_parses_zero_days_test() {
  assert_parses(
    "P0D",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 0,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_fractional_hour_near_one_test() {
  assert_parses(
    "PT0.999999999H",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 59,
      seconds: 59,
      milliseconds: 999,
      microseconds: 996,
      nanoseconds: 400,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_small_fractional_hour_test() {
  assert_parses(
    "PT0.000000011H",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 39,
      nanoseconds: 600,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_fractional_minute_near_one_test() {
  assert_parses(
    "PT0.999999999M",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 59,
      milliseconds: 999,
      microseconds: 999,
      nanoseconds: 940,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_small_fractional_minute_test() {
  assert_parses(
    "PT0.000000011M",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 660,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_fractional_second_near_one_test() {
  assert_parses(
    "PT0.999999999S",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 999,
      microseconds: 999,
      nanoseconds: 999,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/argument-string-fractional-precision.js
pub fn duration_from_parses_small_fractional_second_test() {
  assert_parses(
    "PT0.000000011S",
    Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 0,
      nanoseconds: 11,
    ),
  )
}
