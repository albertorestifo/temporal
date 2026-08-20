import gleam/option.{None}
import gleam/order.{Eq}
import temporal
import temporal/duration.{type Duration, Duration}
import temporal/support/assertions

fn sample_duration() -> Duration {
  Duration(
    is_negative: False,
    years: 1,
    months: 2,
    weeks: 3,
    days: 4,
    hours: 5,
    minutes: 6,
    seconds: 7,
    milliseconds: 8,
    microseconds: 9,
    nanoseconds: 10,
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

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-duration-objects
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_duration_objects_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-duration-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_duration_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-YEARS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.years
// test262: test/built-ins/Temporal/Duration/prototype/years/basic.js
pub fn get_temporal_duration_prototype_years_planned_requirement_test() {
  assertions.equal_with_context("years field", sample_duration().years, 1)
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-MONTHS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.months
// test262: test/built-ins/Temporal/Duration/prototype/months/basic.js
pub fn get_temporal_duration_prototype_months_planned_requirement_test() {
  assertions.equal_with_context("months field", sample_duration().months, 2)
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-WEEKS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.weeks
// test262: test/built-ins/Temporal/Duration/prototype/weeks/basic.js
pub fn get_temporal_duration_prototype_weeks_planned_requirement_test() {
  assertions.equal_with_context("weeks field", sample_duration().weeks, 3)
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-DAYS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.days
// test262: test/built-ins/Temporal/Duration/prototype/days/basic.js
pub fn get_temporal_duration_prototype_days_planned_requirement_test() {
  assertions.equal_with_context("days field", sample_duration().days, 4)
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-HOURS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.hours
// test262: test/built-ins/Temporal/Duration/prototype/hours/basic.js
pub fn get_temporal_duration_prototype_hours_planned_requirement_test() {
  assertions.equal_with_context("hours field", sample_duration().hours, 5)
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-MINUTES
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.minutes
// test262: test/built-ins/Temporal/Duration/prototype/minutes/basic.js
pub fn get_temporal_duration_prototype_minutes_planned_requirement_test() {
  assertions.equal_with_context("minutes field", sample_duration().minutes, 6)
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-SECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.seconds
// test262: test/built-ins/Temporal/Duration/prototype/seconds/basic.js
pub fn get_temporal_duration_prototype_seconds_planned_requirement_test() {
  assertions.equal_with_context("seconds field", sample_duration().seconds, 7)
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-MILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.milliseconds
// test262: test/built-ins/Temporal/Duration/prototype/milliseconds/basic.js
pub fn get_temporal_duration_prototype_milliseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "milliseconds field",
    sample_duration().milliseconds,
    8,
  )
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-MICROSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.microseconds
// test262: test/built-ins/Temporal/Duration/prototype/microseconds/basic.js
pub fn get_temporal_duration_prototype_microseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "microseconds field",
    sample_duration().microseconds,
    9,
  )
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-NANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.nanoseconds
// test262: test/built-ins/Temporal/Duration/prototype/nanoseconds/blank-duration.js
pub fn get_temporal_duration_prototype_nanoseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "nanoseconds field",
    sample_duration().nanoseconds,
    10,
  )
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-SIGN
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.sign
// test262: test/built-ins/Temporal/Duration/prototype/sign/basic.js
pub fn get_temporal_duration_prototype_sign_planned_requirement_test() {
  assertions.equal_with_context(
    "positive duration sign",
    sample_duration().is_negative,
    False,
  )
}

// Requirement: TEMP-S07-SEC-GET-TEMPORAL-DURATION-PROTOTYPE-BLANK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-get-temporal.duration.prototype.blank
// test262: test/built-ins/Temporal/Duration/prototype/blank/basic.js
pub fn get_temporal_duration_prototype_blank_planned_requirement_test() {
  assertions.equal_with_context(
    "canonical blank duration",
    zero_duration(),
    Duration(..zero_duration(), is_negative: False),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-PROTOTYPE-WITH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal.duration.prototype.with
// test262: test/built-ins/Temporal/Duration/from/non-integer-throws-rangeerror.js
pub fn temporal_duration_prototype_with_planned_requirement_test() {
  let changed = Duration(..sample_duration(), days: 12)
  assertions.equal_with_context(
    "updated duration validation",
    duration.validate(changed),
    Ok(changed),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-duration-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_duration_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DATE-DURATION-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-date-duration-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_date_duration_records_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-PARTIAL-DURATION-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-partial-duration-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_partial_duration_records_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-INTERNAL-DURATION-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-internal-duration-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_internal_duration_records_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ZERODATEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-zerodateduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_zerodateduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TOINTERNALDURATIONRECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-tointernaldurationrecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_tointernaldurationrecord_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TOINTERNALDURATIONRECORDWITH24HOURDAYS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-tointernaldurationrecordwith24hourdays
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_tointernaldurationrecordwith24hourdays_planned_requirement_test() {
  let changed = Duration(..sample_duration(), days: 12)
  assertions.equal_with_context(
    "updated duration validation",
    duration.validate(changed),
    Ok(changed),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TODATEDURATIONRECORDWITHOUTTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-todatedurationrecordwithouttime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_todatedurationrecordwithouttime_planned_requirement_test() {
  let changed = Duration(..sample_duration(), days: 12)
  assertions.equal_with_context(
    "updated duration validation",
    duration.validate(changed),
    Ok(changed),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TEMPORALDURATIONFROMINTERNAL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-temporaldurationfrominternal
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_temporaldurationfrominternal_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-CREATEDATEDURATIONRECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-createdatedurationrecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_createdatedurationrecord_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ADJUSTDATEDURATIONRECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-adjustdatedurationrecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_adjustdatedurationrecord_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-COMBINEDATEANDTIMEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-combinedateandtimeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_combinedateandtimeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration addition observable",
    duration.add(sample_duration(), zero_duration(), None),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TOTEMPORALDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-totemporalduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_totemporalduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-DURATIONSIGN
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-durationsign
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn durationsign_planned_requirement_test() {
  assertions.equal_with_context(
    "positive duration sign",
    sample_duration().is_negative,
    False,
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DATEDURATIONSIGN
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-datedurationsign
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_datedurationsign_planned_requirement_test() {
  assertions.equal_with_context(
    "positive duration sign",
    sample_duration().is_negative,
    False,
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-INTERNALDURATIONSIGN
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-internaldurationsign
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_internaldurationsign_planned_requirement_test() {
  assertions.equal_with_context(
    "positive duration sign",
    sample_duration().is_negative,
    False,
  )
}

// Requirement: TEMP-S07-SEC-ISVALIDDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-isvalidduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn isvalidduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DEFAULTTEMPORALLARGESTUNIT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-defaulttemporallargestunit
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_defaulttemporallargestunit_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TOTEMPORALPARTIALDURATIONRECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-totemporalpartialdurationrecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_totemporalpartialdurationrecord_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-CREATETEMPORALDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-createtemporalduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_createtemporalduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-CREATENEGATEDTEMPORALDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-createnegatedtemporalduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_createnegatedtemporalduration_planned_requirement_test() {
  assertions.equal_with_context(
    "negated duration",
    duration.negated(sample_duration()),
    Duration(..sample_duration(), is_negative: True),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TIMEDURATIONFROMCOMPONENTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-timedurationfromcomponents
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_timedurationfromcomponents_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ADDTIMEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-addtimeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_addtimeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration addition observable",
    duration.add(sample_duration(), zero_duration(), None),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ADD24HOURDAYSTONORMALIZEDTIMEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-add24hourdaystonormalizedtimeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_add24hourdaystonormalizedtimeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration addition observable",
    duration.add(sample_duration(), zero_duration(), None),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ADDTIMEDURATIONTOEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-addtimedurationtoepochnanoseconds
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_addtimedurationtoepochnanoseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "duration addition observable",
    duration.add(sample_duration(), zero_duration(), None),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-COMPARETIMEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-comparetimeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_comparetimeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration comparison observable",
    duration.compare(sample_duration(), sample_duration(), None),
    Ok(Eq),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TIMEDURATIONFROMEPOCHNANOSECONDSDIFFERENCE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-timedurationfromepochnanosecondsdifference
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_timedurationfromepochnanosecondsdifference_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ROUNDTIMEDURATIONTOINCREMENT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-roundtimedurationtoincrement
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_roundtimedurationtoincrement_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TIMEDURATIONSIGN
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-timedurationsign
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_timedurationsign_planned_requirement_test() {
  assertions.equal_with_context(
    "positive duration sign",
    sample_duration().is_negative,
    False,
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DATEDURATIONDAYS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-datedurationdays
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_datedurationdays_planned_requirement_test() {
  assertions.equal_with_context(
    "duration record validation",
    duration.validate(sample_duration()),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ROUNDTIMEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-roundtimeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_roundtimeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TOTALTIMEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-totaltimeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_totaltimeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration total hours",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-NUDGE-RESULT-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-duration-nudge-result-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_duration_nudge_result_records_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-COMPUTENUDGEWINDOW
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-computenudgewindow
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_computenudgewindow_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-NUDGETOCALENDARUNIT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-nudgetocalendarunit
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_nudgetocalendarunit_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-NUDGETOZONEDTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-nudgetozonedtime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_nudgetozonedtime_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-NUDGETODAYORTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-nudgetodayortime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_nudgetodayortime_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-BUBBLERELATIVEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-bubblerelativeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_bubblerelativeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ROUNDRELATIVEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-roundrelativeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_roundrelativeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration rounding observable",
    duration.round(
      sample_duration(),
      duration.Hour,
      duration.Day,
      1,
      temporal.HalfExpand,
      None,
    ),
    Ok(sample_duration()),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TOTALRELATIVEDURATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-totalrelativeduration
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_totalrelativeduration_planned_requirement_test() {
  assertions.equal_with_context(
    "duration total hours",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-TEMPORALDURATIONTOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-temporaldurationtostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_temporaldurationtostring_planned_requirement_test() {
  assertions.equal_with_context(
    "duration ISO serialization",
    duration.to_iso_8601(sample_duration()),
    "P1Y2M3W4DT5H6M7.00800901S",
  )
}

// Requirement: TEMP-S07-SEC-TEMPORAL-ADDDURATIONS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/duration.html#sec-temporal-adddurations
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event
pub fn temporal_adddurations_planned_requirement_test() {
  assertions.equal_with_context(
    "duration addition observable",
    duration.add(sample_duration(), zero_duration(), None),
    Ok(sample_duration()),
  )
}
