import bigi
import gleam/order.{Eq}
import temporal
import temporal/calendar
import temporal/duration.{type Duration, Duration}
import temporal/instant
import temporal/support/assertions
import temporal/time_zone
import temporal/zoned_date_time

fn epoch() -> instant.Instant {
  assertions.is_ok_with_context(
    "epoch fixture",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
  )
}

fn zero_duration() -> Duration {
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
  )
}

fn difference_options() -> duration.DifferenceOptions {
  duration.DifferenceOptions(
    largest_unit: duration.Second,
    smallest_unit: duration.Nanosecond,
    rounding_increment: 1,
    rounding_mode: temporal.Trunc,
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-instant-objects
// test262: test/built-ins/Temporal/Instant/prototype/builtin.js
pub fn temporal_instant_objects_planned_requirement_test() {
  assertions.equal_with_context(
    "Instant construction",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-instant-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_instant_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "Instant construction",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant
// test262: test/built-ins/Temporal/Duration/get-prototype-from-constructor-throws.js
pub fn temporal_instant_planned_requirement_test() {
  assertions.equal_with_context(
    "Instant construction",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-PROTOTYPE-TOZONEDDATETIMEISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal.instant.prototype.tozoneddatetimeiso
// test262: test/built-ins/Temporal/Instant/prototype/toZonedDateTimeISO/branding.js
pub fn temporal_instant_prototype_tozoneddatetimeiso_planned_requirement_test() {
  let got =
    zoned_date_time.from_instant(epoch(), time_zone.utc(), calendar.Iso8601)
  assertions.is_ok_with_context("UTC zoned conversion", got)
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-RANGE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-instant-range
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_instant_range_planned_requirement_test() {
  let above_limit =
    assertions.is_ok_with_context(
      "BigInt limit fixture",
      bigi.from_string("8640000000000000000001"),
    )
  assertions.is_error_with_context(
    "above positive Instant limit",
    instant.from_epoch_nanoseconds(above_limit),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-instant-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_instant_abstract_ops_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO instant conversion",
    instant.from_iso_8601("1970-01-01T00:00:00Z"),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-ISVALIDEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-isvalidepochnanoseconds
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_isvalidepochnanoseconds_planned_requirement_test() {
  let above_limit =
    assertions.is_ok_with_context(
      "BigInt limit fixture",
      bigi.from_string("8640000000000000000001"),
    )
  assertions.is_error_with_context(
    "above positive Instant limit",
    instant.from_epoch_nanoseconds(above_limit),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-CREATETEMPORALINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-createtemporalinstant
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_createtemporalinstant_planned_requirement_test() {
  assertions.equal_with_context(
    "Instant construction",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-TOTEMPORALINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-totemporalinstant
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_totemporalinstant_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO instant conversion",
    instant.from_iso_8601("1970-01-01T00:00:00Z"),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-COMPAREEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-compareepochnanoseconds
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_compareepochnanoseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "equal epoch nanoseconds",
    instant.compare(epoch(), epoch()),
    Eq,
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-ADDINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-addinstant
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_addinstant_planned_requirement_test() {
  assertions.equal_with_context(
    "instant addition observable",
    instant.add(epoch(), zero_duration()),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-DIFFERENCEINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-differenceinstant
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_differenceinstant_planned_requirement_test() {
  assertions.equal_with_context(
    "instant difference observable",
    instant.until(epoch(), epoch(), difference_options()),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-ROUNDTEMPORALINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-roundtemporalinstant
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_roundtemporalinstant_planned_requirement_test() {
  assertions.equal_with_context(
    "instant rounding observable",
    instant.round(epoch(), duration.Second, 1, temporal.HalfExpand),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-TEMPORALINSTANTTOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-temporalinstanttostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_temporalinstanttostring_planned_requirement_test() {
  assertions.equal_with_context(
    "Instant ISO serialization",
    instant.to_iso_8601(epoch()),
    "1970-01-01T00:00:00Z",
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-DIFFERENCETEMPORALINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-differencetemporalinstant
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_differencetemporalinstant_planned_requirement_test() {
  assertions.equal_with_context(
    "instant difference observable",
    instant.until(epoch(), epoch(), difference_options()),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S08-SEC-TEMPORAL-ADDDURATIONTOINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/instant.html#sec-temporal-adddurationtoinstant
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp
pub fn temporal_adddurationtoinstant_planned_requirement_test() {
  assertions.equal_with_context(
    "instant addition observable",
    instant.add(epoch(), zero_duration()),
    Ok(epoch()),
  )
}
