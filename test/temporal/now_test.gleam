import bigi
import gleam/option.{None, Some}
import gleam/order.{Gt}
import temporal/instant
import temporal/now
import temporal/support/assertions
import temporal/time_zone
import temporal/zoned_date_time

fn fixed_clock_at(nanoseconds: Int, zone: time_zone.TimeZone) -> now.Clock {
  now.fixed_clock(instant: bigi.from_int(nanoseconds), time_zone: zone)
}

fn offset_zone(offset: String) -> time_zone.TimeZone {
  assertions.is_ok_with_context(
    "fixed numeric offset",
    time_zone.from_offset(offset),
  )
}

// Requirement: TEMP-S01-SEC-TEMPORAL-NOW
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal-now
pub fn temporal_now_module_exposes_clock_semantics_test() {
  let clock = fixed_clock_at(42, time_zone.utc())
  assertions.equal_with_context(
    "Now module instant",
    now.instant_with_clock(clock),
    Ok(bigi.from_int(42)),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-OBJECT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal-now-object
// test262: test/built-ins/Temporal/Now/builtin.js
pub fn now_fixed_clocks_are_independent_values_test() {
  let first = fixed_clock_at(1, time_zone.utc())
  let second = fixed_clock_at(2, offset_zone("+01:00"))
  assertions.equal_with_context(
    "first clock",
    now.instant_with_clock(first),
    Ok(bigi.from_int(1)),
  )
  assertions.equal_with_context(
    "second clock",
    now.instant_with_clock(second),
    Ok(bigi.from_int(2)),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-TIMEZONEID
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal.now.timezoneid
// test262: test/built-ins/Temporal/Now/timeZoneId/return-value.js
pub fn now_fixed_clock_returns_time_zone_id_test() {
  let clock = fixed_clock_at(0, offset_zone("+05:30"))
  assertions.equal_with_context(
    "fixed time-zone identifier",
    now.time_zone_id_with_clock(clock),
    Ok("+05:30"),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-INSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal.now.instant
// test262: test/built-ins/Temporal/Now/instant/return-value-value.js
pub fn now_fixed_clock_returns_exact_instant_test() {
  let expected = bigi.from_int(1_234_567_890)
  let clock = now.fixed_clock(instant: expected, time_zone: time_zone.utc())
  assertions.equal_with_context(
    "fixed instant",
    now.instant_with_clock(clock),
    Ok(expected),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-ZONEDDATETIMEISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal.now.zoneddatetimeiso
// test262: test/built-ins/Temporal/Now/zonedDateTimeISO/return-value.js
pub fn now_zoned_date_time_iso_uses_iso_calendar_test() {
  let clock = fixed_clock_at(1000, time_zone.utc())
  let value =
    assertions.is_ok_with_context(
      "zoned date-time from fixed clock",
      now.zoned_date_time_iso_with_clock(clock, time_zone: None),
    )
  assertions.equal_with_context(
    "calendar identifier",
    zoned_date_time.calendar_id(value),
    "iso8601",
  )
  assertions.equal_with_context(
    "epoch nanoseconds",
    zoned_date_time.epoch_nanoseconds(value),
    bigi.from_int(1000),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-ZONEDDATETIMEISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal.now.zoneddatetimeiso
// test262: test/built-ins/Temporal/Now/zonedDateTimeISO/timezone-string.js
pub fn now_zoned_date_time_iso_uses_requested_time_zone_test() {
  let clock = fixed_clock_at(1000, time_zone.utc())
  let value =
    assertions.is_ok_with_context(
      "zoned date-time in requested zone",
      now.zoned_date_time_iso_with_clock(
        clock,
        time_zone: Some(offset_zone("-08:00")),
      ),
    )
  assertions.equal_with_context(
    "time-zone identifier",
    zoned_date_time.time_zone_id(value),
    "-08:00",
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal-now-abstract-ops
pub fn now_fixed_clock_repeats_without_global_state_test() {
  let clock = fixed_clock_at(-99, time_zone.utc())
  let first = now.instant_with_clock(clock)
  let second = now.instant_with_clock(clock)
  assertions.equal_with_context("repeat fixed-clock read", second, first)
}

// Requirement: TEMP-S02-SEC-HOSTSYSTEMUTCEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-hostsystemutcepochnanoseconds
pub fn now_system_clock_returns_current_era_instant_test() {
  let current =
    assertions.is_ok_with_context("system clock instant", now.instant())
  let year_2017 = bigi.from_int(1_500_000_000_000_000_000)
  assertions.equal_with_context(
    "system instant is after 2017",
    instant.compare(current, year_2017),
    Gt,
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-SYSTEMUTCEPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal-systemutcepochmilliseconds
pub fn now_system_clock_instant_has_millisecond_precision_test() {
  let current =
    assertions.is_ok_with_context("system clock instant", now.instant())
  let reconstructed =
    instant.from_epoch_milliseconds(instant.epoch_milliseconds(current))
  assertions.equal_with_context(
    "millisecond-aligned system instant",
    reconstructed,
    Ok(current),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-SYSTEMUTCEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal-systemutcepochnanoseconds
pub fn now_system_clock_instant_is_within_temporal_range_test() {
  let current =
    assertions.is_ok_with_context("system clock instant", now.instant())
  assertions.is_ok_with_context(
    "validated system epoch nanoseconds",
    instant.from_epoch_nanoseconds_int(current),
  )
}
