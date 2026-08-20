import bigi
import gleam/order.{Eq, Gt, Lt}
import temporal
import temporal/duration
import temporal/instant
import temporal/support/assertions
import temporal/support/plain_fixtures

const max_epoch_milliseconds = 8_640_000_000_000_000

fn max_epoch_nanoseconds() {
  bigi.multiply(bigi.from_int(max_epoch_milliseconds), bigi.from_int(1_000_000))
}

fn negate(value: bigi.BigInt) {
  bigi.multiply(value, bigi.from_int(-1))
}

fn increment(value: bigi.BigInt) {
  bigi.add(value, bigi.from_int(1))
}

fn decrement(value: bigi.BigInt) {
  bigi.add(value, bigi.from_int(-1))
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochmilliseconds
// test262: test/built-ins/Temporal/Instant/fromEpochMilliseconds/basic.js
pub fn instant_from_epoch_milliseconds_constructs_exact_value_test() {
  let got =
    assertions.is_ok_with_context(
      "one second after epoch",
      instant.from_epoch_milliseconds(1000),
    )
  assertions.equal_with_context(
    "epoch nanoseconds",
    got,
    bigi.from_int(1_000_000_000),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochmilliseconds
// test262: test/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.js
pub fn instant_from_epoch_milliseconds_accepts_positive_limit_test() {
  assertions.is_ok_with_context(
    "positive 10^8-day limit",
    instant.from_epoch_milliseconds(max_epoch_milliseconds),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochmilliseconds
// test262: test/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.js
pub fn instant_from_epoch_milliseconds_accepts_negative_limit_test() {
  assertions.is_ok_with_context(
    "negative 10^8-day limit",
    instant.from_epoch_milliseconds(-max_epoch_milliseconds),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochmilliseconds
// test262: test/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.js
pub fn instant_from_epoch_milliseconds_rejects_above_positive_limit_test() {
  assertions.is_error_with_context(
    "one millisecond above positive limit",
    instant.from_epoch_milliseconds(max_epoch_milliseconds + 1),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochmilliseconds
// test262: test/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.js
pub fn instant_from_epoch_milliseconds_rejects_below_negative_limit_test() {
  assertions.is_error_with_context(
    "one millisecond below negative limit",
    instant.from_epoch_milliseconds(-max_epoch_milliseconds - 1),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochnanoseconds
// test262: test/built-ins/Temporal/Instant/fromEpochNanoseconds/basic.js
pub fn instant_from_epoch_nanoseconds_constructs_exact_value_test() {
  let expected = bigi.from_int(123_456_789)
  let got =
    assertions.is_ok_with_context(
      "epoch nanoseconds",
      instant.from_epoch_nanoseconds_int(expected),
    )
  assertions.equal_with_context("epoch nanoseconds", got, expected)
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochnanoseconds
// test262: test/built-ins/Temporal/Instant/fromEpochNanoseconds/limits.js
pub fn instant_from_epoch_nanoseconds_accepts_positive_limit_test() {
  assertions.is_ok_with_context(
    "positive 10^8-day limit",
    instant.from_epoch_nanoseconds_int(max_epoch_nanoseconds()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochnanoseconds
// test262: test/built-ins/Temporal/Instant/fromEpochNanoseconds/limits.js
pub fn instant_from_epoch_nanoseconds_accepts_negative_limit_test() {
  assertions.is_ok_with_context(
    "negative 10^8-day limit",
    instant.from_epoch_nanoseconds_int(negate(max_epoch_nanoseconds())),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochnanoseconds
// test262: test/built-ins/Temporal/Instant/fromEpochNanoseconds/limits.js
pub fn instant_from_epoch_nanoseconds_rejects_above_positive_limit_test() {
  assertions.is_error_with_context(
    "one nanosecond above positive limit",
    instant.from_epoch_nanoseconds_int(increment(max_epoch_nanoseconds())),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROMEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.fromepochnanoseconds
// test262: test/built-ins/Temporal/Instant/fromEpochNanoseconds/limits.js
pub fn instant_from_epoch_nanoseconds_rejects_below_negative_limit_test() {
  assertions.is_error_with_context(
    "one nanosecond below negative limit",
    instant.from_epoch_nanoseconds_int(
      decrement(negate(max_epoch_nanoseconds())),
    ),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.compare
// test262: test/built-ins/Temporal/Instant/compare/exhaustive.js
pub fn instant_compare_returns_less_than_test() {
  assertions.equal_with_context(
    "earlier instant",
    instant.compare(bigi.from_int(-1000), bigi.from_int(1000)),
    Lt,
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.compare
// test262: test/built-ins/Temporal/Instant/compare/exhaustive.js
pub fn instant_compare_returns_equal_test() {
  assertions.equal_with_context(
    "equal instants",
    instant.compare(bigi.from_int(123_456_789), bigi.from_int(123_456_789)),
    Eq,
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.compare
// test262: test/built-ins/Temporal/Instant/compare/exhaustive.js
pub fn instant_compare_returns_greater_than_test() {
  assertions.equal_with_context(
    "later instant",
    instant.compare(bigi.from_int(1000), bigi.from_int(-1000)),
    Gt,
  )
}

// Requirement: TEMP-S08-SEC-GET-TEMPORAL-INSTANT-PROTOTYPE-EPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-get-temporal.instant.prototype.epochmilliseconds
// test262: test/built-ins/Temporal/Instant/prototype/epochMilliseconds/basic.js
pub fn instant_epoch_milliseconds_floors_positive_submilliseconds_test() {
  let value = bigi.from_int(217_175_010_123_456_789)
  assertions.equal_with_context(
    "positive epoch milliseconds",
    instant.epoch_milliseconds(value),
    217_175_010_123,
  )
}

// Requirement: TEMP-S08-SEC-GET-TEMPORAL-INSTANT-PROTOTYPE-EPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-get-temporal.instant.prototype.epochmilliseconds
// test262: test/built-ins/Temporal/Instant/prototype/epochMilliseconds/basic.js
pub fn instant_epoch_milliseconds_floors_negative_submilliseconds_test() {
  let value = bigi.from_int(-217_175_010_876_543_211)
  assertions.equal_with_context(
    "negative epoch milliseconds",
    instant.epoch_milliseconds(value),
    -217_175_010_877,
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.from
// test262: test/built-ins/Temporal/Instant/from/argument-string.js
pub fn instant_from_iso_8601_parses_offset_string_test() {
  assertions.is_ok_with_context(
    "UTC instant",
    instant.from_iso_8601("1970-01-01T00:00:00Z"),
  )
}

// Requirement: TEMP-S08-SEC-GET-TEMPORAL-INSTANT-PROTOTYPE-EPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-get-temporal.instant.prototype.epochnanoseconds
// test262: test/built-ins/Temporal/Instant/prototype/epochNanoseconds/basic.js
pub fn instant_epoch_nanoseconds_returns_exact_value_test() {
  let value = bigi.from_int(123_456_789)
  assertions.equal_with_context(
    "epoch nanoseconds",
    instant.epoch_nanoseconds(value),
    value,
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-EQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.equals
// test262: test/built-ins/Temporal/Instant/prototype/equals/basic.js
pub fn instant_equal_matches_same_epoch_nanoseconds_test() {
  let value = bigi.from_int(123_456_789)
  assertions.equal_with_context(
    "same instant",
    instant.equal(value, value),
    True,
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-ADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.add
// test262: test/built-ins/Temporal/Instant/prototype/add/basic.js
pub fn instant_add_applies_time_duration_test() {
  assertions.is_ok_with_context(
    "instant addition",
    instant.add(bigi.from_int(0), plain_fixtures.one_day()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-SUBTRACT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.subtract
// test262: test/built-ins/Temporal/Instant/prototype/subtract/basic.js
pub fn instant_subtract_applies_time_duration_test() {
  assertions.is_ok_with_context(
    "instant subtraction",
    instant.subtract(bigi.from_int(0), plain_fixtures.one_day()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-UNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.until
// test262: test/built-ins/Temporal/Instant/prototype/until/subseconds.js
pub fn instant_until_returns_duration_test() {
  assertions.is_ok_with_context(
    "instant until",
    instant.until(
      bigi.from_int(0),
      bigi.from_int(1_000_000_000),
      plain_fixtures.difference_options(),
    ),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-SINCE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.since
// test262: test/built-ins/Temporal/Instant/prototype/since/subseconds.js
pub fn instant_since_returns_duration_test() {
  assertions.is_ok_with_context(
    "instant since",
    instant.since(
      bigi.from_int(1_000_000_000),
      bigi.from_int(0),
      plain_fixtures.difference_options(),
    ),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-ROUND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.round
// test262: test/built-ins/Temporal/Instant/prototype/round/rounding-increments.js
pub fn instant_round_uses_typed_unit_test() {
  assertions.is_ok_with_context(
    "instant rounding",
    instant.round(
      bigi.from_int(1_500_000_000),
      duration.Second,
      1,
      temporal.HalfExpand,
    ),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.tostring
// test262: test/built-ins/Temporal/Instant/prototype/toString/basic.js
pub fn instant_to_iso_8601_formats_utc_test() {
  assertions.equal_with_context(
    "epoch ISO string",
    instant.to_iso_8601(bigi.from_int(0)),
    "1970-01-01T00:00:00Z",
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.tojson
// test262: test/built-ins/Temporal/Instant/prototype/toJSON/basic.js
pub fn instant_to_iso_8601_is_json_representation_test() {
  assertions.equal_with_context(
    "epoch JSON string",
    instant.to_iso_8601(bigi.from_int(0)),
    "1970-01-01T00:00:00Z",
  )
}
