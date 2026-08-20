import gleam/order.{Lt}
import temporal
import temporal/duration
import temporal/plain_time
import temporal/support/assertions
import temporal/support/plain_fixtures

fn fixture() {
  plain_time.fixture(
    hour: 12,
    minute: 34,
    second: 56,
    millisecond: 123,
    microsecond: 456,
    nanosecond: 789,
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime
// test262: test/built-ins/Temporal/PlainTime/basic.js
pub fn plain_time_new_accepts_iso_time_test() {
  assertions.is_ok_with_context(
    "valid ISO time",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Reject,
    ),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.from
// test262: test/built-ins/Temporal/PlainTime/from/argument-string.js
pub fn plain_time_from_iso_8601_parses_time_test() {
  assertions.is_ok_with_context(
    "ISO time",
    plain_time.from_iso_8601("12:34:56.123456789"),
  )
}

// Requirement: TEMP-S04-SEC-GET-TEMPORAL-PLAINTIME-PROTOTYPE-HOUR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-get-temporal.plaintime.prototype.hour
// test262: test/built-ins/Temporal/PlainTime/prototype/hour/basic.js
pub fn plain_time_hour_returns_hour_test() {
  assertions.equal_with_context(
    "plain_time_hour_returns_hour",
    plain_time.hour(fixture()),
    12,
  )
}

// Requirement: TEMP-S04-SEC-GET-TEMPORAL-PLAINTIME-PROTOTYPE-MINUTE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-get-temporal.plaintime.prototype.minute
// test262: test/built-ins/Temporal/PlainTime/prototype/minute/basic.js
pub fn plain_time_minute_returns_minute_test() {
  assertions.equal_with_context(
    "plain_time_minute_returns_minute",
    plain_time.minute(fixture()),
    34,
  )
}

// Requirement: TEMP-S04-SEC-GET-TEMPORAL-PLAINTIME-PROTOTYPE-SECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-get-temporal.plaintime.prototype.second
// test262: test/built-ins/Temporal/PlainTime/prototype/second/basic.js
pub fn plain_time_second_returns_second_test() {
  assertions.equal_with_context(
    "plain_time_second_returns_second",
    plain_time.second(fixture()),
    56,
  )
}

// Requirement: TEMP-S04-SEC-GET-TEMPORAL-PLAINTIME-PROTOTYPE-MILLISECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-get-temporal.plaintime.prototype.millisecond
// test262: test/built-ins/Temporal/PlainTime/prototype/millisecond/basic.js
pub fn plain_time_millisecond_returns_millisecond_test() {
  assertions.equal_with_context(
    "plain_time_millisecond_returns_millisecond",
    plain_time.millisecond(fixture()),
    123,
  )
}

// Requirement: TEMP-S04-SEC-GET-TEMPORAL-PLAINTIME-PROTOTYPE-MICROSECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-get-temporal.plaintime.prototype.microsecond
// test262: test/built-ins/Temporal/PlainTime/prototype/microsecond/basic.js
pub fn plain_time_microsecond_returns_microsecond_test() {
  assertions.equal_with_context(
    "plain_time_microsecond_returns_microsecond",
    plain_time.microsecond(fixture()),
    456,
  )
}

// Requirement: TEMP-S04-SEC-GET-TEMPORAL-PLAINTIME-PROTOTYPE-NANOSECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-get-temporal.plaintime.prototype.nanosecond
// test262: test/built-ins/Temporal/PlainTime/prototype/nanosecond/basic.js
pub fn plain_time_nanosecond_returns_nanosecond_test() {
  assertions.equal_with_context(
    "plain_time_nanosecond_returns_nanosecond",
    plain_time.nanosecond(fixture()),
    789,
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.compare
// test262: test/built-ins/Temporal/PlainTime/compare/basic.js
pub fn plain_time_compare_orders_fields_test() {
  let later =
    plain_time.fixture(
      hour: 13,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
      nanosecond: 0,
    )
  assertions.equal_with_context(
    "time order",
    plain_time.compare(fixture(), later),
    Lt,
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-EQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.equals
// test262: test/built-ins/Temporal/PlainTime/prototype/equals/basic.js
pub fn plain_time_equal_matches_same_time_test() {
  assertions.equal_with_context(
    "same time",
    plain_time.equal(fixture(), fixture()),
    True,
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-ADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.add
// test262: test/built-ins/Temporal/PlainTime/prototype/add/basic.js
pub fn plain_time_add_wraps_across_midnight_test() {
  assertions.is_ok_with_context(
    "add",
    plain_time.add(fixture(), plain_fixtures.one_day()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-SUBTRACT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.subtract
// test262: test/built-ins/Temporal/PlainTime/prototype/subtract/basic.js
pub fn plain_time_subtract_wraps_across_midnight_test() {
  assertions.is_ok_with_context(
    "subtract",
    plain_time.subtract(fixture(), plain_fixtures.one_day()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-UNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.until
// test262: test/built-ins/Temporal/PlainTime/prototype/until/basic.js
pub fn plain_time_until_returns_duration_test() {
  assertions.is_ok_with_context(
    "until",
    plain_time.until(fixture(), fixture(), plain_fixtures.difference_options()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-SINCE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.since
// test262: test/built-ins/Temporal/PlainTime/prototype/since/basic.js
pub fn plain_time_since_returns_duration_test() {
  assertions.is_ok_with_context(
    "since",
    plain_time.since(fixture(), fixture(), plain_fixtures.difference_options()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-ROUND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.round
// test262: test/built-ins/Temporal/PlainTime/prototype/round/roundingincrement-minutes.js
pub fn plain_time_round_uses_typed_unit_test() {
  assertions.is_ok_with_context(
    "round",
    plain_time.round(fixture(), duration.Minute, 15, temporal.HalfExpand),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.tostring
// test262: test/built-ins/Temporal/PlainTime/prototype/toString/basic.js
pub fn plain_time_to_iso_8601_formats_time_test() {
  assertions.equal_with_context(
    "ISO time",
    plain_time.to_iso_8601(fixture()),
    "12:34:56.123456789",
  )
}
