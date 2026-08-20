import gleam/option.{None}
import gleam/order.{Eq}
import temporal
import temporal/duration.{type Duration, Duration, from_iso_8601}
import temporal/support/assertions
import temporal/support/plain_fixtures

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

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration
// test262: test/built-ins/Temporal/Duration/basic.js
pub fn duration_validate_accepts_canonical_literal_test() {
  assertions.is_ok_with_context(
    "canonical literal",
    duration.validate(plain_fixtures.one_day()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.compare
// test262: test/built-ins/Temporal/Duration/compare/basic.js
pub fn duration_compare_orders_time_durations_test() {
  assertions.equal_with_context(
    "equal duration",
    duration.compare(plain_fixtures.one_day(), plain_fixtures.one_day(), None),
    Ok(Eq),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-NEGATED
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.negated
// test262: test/built-ins/Temporal/Duration/prototype/negated/basic.js
pub fn duration_negated_reverses_sign_test() {
  let value = plain_fixtures.one_day()
  assertions.equal_with_context(
    "negative duration",
    duration.negated(value),
    Duration(..value, is_negative: True),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-ABS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.abs
// test262: test/built-ins/Temporal/Duration/prototype/abs/basic.js
pub fn duration_absolute_removes_negative_sign_test() {
  let value = Duration(..plain_fixtures.one_day(), is_negative: True)
  assertions.equal_with_context(
    "absolute duration",
    duration.absolute(value),
    Duration(..value, is_negative: False),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-ADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.add
// test262: test/built-ins/Temporal/Duration/prototype/add/basic.js
pub fn duration_add_combines_time_fields_test() {
  assertions.is_ok_with_context(
    "duration addition",
    duration.add(plain_fixtures.one_day(), plain_fixtures.one_day(), None),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-SUBTRACT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.subtract
// test262: test/built-ins/Temporal/Duration/prototype/subtract/basic.js
pub fn duration_subtract_combines_time_fields_test() {
  assertions.is_ok_with_context(
    "duration subtraction",
    duration.subtract(plain_fixtures.one_day(), plain_fixtures.one_day(), None),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-ROUND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.round
// test262: test/built-ins/Temporal/Duration/prototype/round/roundingincrement-hours.js
pub fn duration_round_uses_typed_units_test() {
  assertions.is_ok_with_context(
    "duration rounding",
    duration.round(
      plain_fixtures.one_day(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-TOTAL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.total
// test262: test/built-ins/Temporal/Duration/prototype/total/basic.js
pub fn duration_total_uses_typed_unit_test() {
  assertions.equal_with_context(
    "total hours",
    duration.total(plain_fixtures.one_day(), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.tostring
// test262: test/built-ins/Temporal/Duration/prototype/toString/basic.js
pub fn duration_to_iso_8601_formats_duration_test() {
  assertions.equal_with_context(
    "ISO duration",
    duration.to_iso_8601(plain_fixtures.one_day()),
    "P1D",
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.tojson
// test262: test/built-ins/Temporal/Duration/prototype/toJSON/basic.js
pub fn duration_to_iso_8601_is_json_representation_test() {
  assertions.equal_with_context(
    "JSON duration",
    duration.to_iso_8601(plain_fixtures.one_day()),
    "P1D",
  )
}
