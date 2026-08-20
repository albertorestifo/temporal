import gleam/option.{None}
import temporal.{Ceil, Constrain, Floor, HalfExpand, Reject}
import temporal/duration.{Duration}
import temporal/support/assertions
import temporal/support/foundations

// Requirement: TEMP-S13-SEC-TEMPORAL-PARSETEMPORALDURATIONSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-parsetemporaldurationstring
// test262: test/built-ins/Temporal/Duration/from/string-with-skipped-units.js
pub fn foundations_duration_parser_preserves_weeks_and_days_test() {
  assertions.equal_with_context(
    "weeks and days",
    duration.from_iso_8601("P3W1D"),
    Ok(Duration(
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
    )),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISO8601GRAMMAR-STATIC-SEMANTICS-EARLY-ERRORS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-iso8601grammar-static-semantics-early-errors
// test262: test/built-ins/Temporal/Duration/from/fractional-units.js
pub fn foundations_duration_parser_rejects_fraction_before_smaller_unit_test() {
  assertions.is_error_with_context(
    "fractional hours followed by minutes",
    duration.from_iso_8601("PT1.5H30M"),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-abstract-ops
pub fn foundations_duration_serialization_emits_fractional_seconds_test() {
  assertions.equal_with_context(
    "fractional duration",
    duration.to_iso_8601(Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 1,
      milliseconds: 2,
      microseconds: 3,
      nanoseconds: 4,
    )),
    "PT1.002003004S",
  )
}

// Requirement: TEMP-S13-SEC-ISODATETOEPOCHDAYS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-isodatetoepochdays
pub fn foundations_iso_date_to_epoch_days_maps_unix_epoch_test() {
  assertions.equal_with_context(
    "Unix epoch",
    foundations.iso_date_to_epoch_days(1970, 1, 1),
    Ok(0),
  )
}

// Requirement: TEMP-S13-SEC-ISODATETOEPOCHDAYS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-isodatetoepochdays
pub fn foundations_iso_date_to_epoch_days_handles_leap_century_test() {
  assertions.equal_with_context(
    "day after leap day in 2000",
    foundations.iso_date_to_epoch_days(2000, 3, 1),
    Ok(11_017),
  )
}

// Requirement: TEMP-S13-SEC-EPOCHDAYSTOEPOCHMS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-epochdaystoepochms
pub fn foundations_epoch_days_to_epoch_milliseconds_includes_time_test() {
  assertions.equal_with_context(
    "day plus time",
    foundations.epoch_days_to_epoch_milliseconds(1, 3_723_004),
    Ok(90_123_004),
  )
}

// Requirement: TEMP-S13-SEC-DATE-EQUATIONS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-date-equations
pub fn foundations_balance_iso_date_carries_month_overflow_test() {
  assertions.equal_with_context(
    "thirteenth month",
    foundations.balance_iso_date(2020, 13, 1),
    #(2021, 1, 1),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-abstract-ops
pub fn foundations_balance_time_reports_day_overflow_test() {
  assertions.equal_with_context(
    "twenty-sixth hour and sixty-first minute",
    foundations.balance_time(25, 61, 0, 0, 0, 0),
    #(1, 2, 1, 0, 0, 0, 0),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-abstract-ops
pub fn foundations_duration_add_balances_time_units_test() {
  let got =
    duration.add(
      Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 0,
        hours: 1,
        minutes: 0,
        seconds: 0,
        milliseconds: 0,
        microseconds: 0,
        nanoseconds: 0,
      ),
      Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 0,
        hours: 0,
        minutes: 90,
        seconds: 0,
        milliseconds: 0,
        microseconds: 0,
        nanoseconds: 0,
      ),
      None,
    )

  assertions.equal_with_context(
    "one hour plus ninety minutes",
    got,
    Ok(Duration(
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
    )),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-abstract-ops
pub fn foundations_duration_balance_time_carries_subseconds_test() {
  assertions.equal_with_context(
    "one thousand nanoseconds",
    foundations.balance_duration_time(Duration(
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
      nanoseconds: 1000,
    )),
    Ok(Duration(
      is_negative: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      microseconds: 1,
      nanoseconds: 0,
    )),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALOVERFLOWOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporaloverflowoption
pub fn foundations_overflow_option_accepts_constrain_test() {
  assertions.equal_with_context(
    "constrain option",
    foundations.overflow_option("constrain"),
    Ok(Constrain),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALOVERFLOWOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporaloverflowoption
pub fn foundations_overflow_option_accepts_reject_test() {
  assertions.equal_with_context(
    "reject option",
    foundations.overflow_option("reject"),
    Ok(Reject),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-NEGATEROUNDINGMODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-negateroundingmode
pub fn foundations_negate_rounding_mode_swaps_ceil_and_floor_test() {
  assertions.equal_with_context(
    "negated ceil",
    foundations.negate_rounding_mode(Ceil),
    Floor,
  )
}

// Requirement: TEMP-S13-SEC-VALIDATETEMPORALROUNDINGINCREMENT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-validatetemporalroundingincrement
pub fn foundations_rounding_increment_accepts_divisor_test() {
  assertions.equal_with_context(
    "thirty divides sixty",
    foundations.validate_rounding_increment(30, 60, False),
    Ok(Nil),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ROUNDNUMBERTOINCREMENT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-roundnumbertoincrement
pub fn foundations_round_number_half_expand_breaks_positive_tie_up_test() {
  assertions.equal_with_context(
    "positive tie",
    foundations.round_number_to_increment(15, 10, HalfExpand),
    Ok(20),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ROUNDNUMBERTOINCREMENT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-roundnumbertoincrement
pub fn foundations_round_number_half_expand_breaks_negative_tie_down_test() {
  assertions.equal_with_context(
    "negative tie",
    foundations.round_number_to_increment(-15, 10, HalfExpand),
    Ok(-20),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-FORMATFRACTIONALSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-formatfractionalseconds
pub fn foundations_format_fractional_seconds_emits_requested_precision_test() {
  assertions.equal_with_context(
    "automatic precision",
    foundations.format_fractional_seconds(120_000_000, 9),
    ".120000000",
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-FORMATTIMESTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-formattimestring
pub fn foundations_format_time_string_emits_requested_precision_test() {
  assertions.equal_with_context(
    "millisecond precision",
    foundations.format_time_string(12, 34, 56, 123_000_000, 3),
    "12:34:56.123",
  )
}
