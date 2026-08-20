import bigi
import gleam/order.{Eq, Gt, Lt}
import temporal/instant
import temporal/support/assertions

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
