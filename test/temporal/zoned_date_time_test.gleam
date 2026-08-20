import bigi
import gleam/order.{Lt}
import temporal/calendar
import temporal/support/assertions
import temporal/time_zone
import temporal/zoned_date_time

const max_epoch_milliseconds = 8_640_000_000_000_000

fn max_epoch_nanoseconds() {
  bigi.multiply(bigi.from_int(max_epoch_milliseconds), bigi.from_int(1_000_000))
}

fn at(
  epoch_nanoseconds: bigi.BigInt,
  zone: time_zone.TimeZone,
) -> zoned_date_time.ZonedDateTime {
  assertions.is_ok_with_context(
    "zoned date-time fixture",
    zoned_date_time.from_instant(
      epoch_nanoseconds,
      time_zone: zone,
      calendar: calendar.iso_8601(),
    ),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-zoneddatetime-objects
pub fn zoned_date_time_instance_preserves_exact_time_test() {
  let value = at(bigi.from_int(123_456_789), time_zone.utc())
  assertions.equal_with_context(
    "exact epoch nanoseconds",
    zoned_date_time.epoch_nanoseconds(value),
    bigi.from_int(123_456_789),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime
// test262: test/built-ins/Temporal/ZonedDateTime/construction-and-properties.js
pub fn zoned_date_time_from_instant_constructs_value_test() {
  assertions.is_ok_with_context(
    "epoch in UTC",
    zoned_date_time.from_instant(
      bigi.from_int(0),
      time_zone: time_zone.utc(),
      calendar: calendar.iso_8601(),
    ),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime
// test262: test/built-ins/Temporal/ZonedDateTime/limits.js
pub fn zoned_date_time_from_instant_accepts_positive_limit_test() {
  assertions.is_ok_with_context(
    "positive 10^8-day limit",
    zoned_date_time.from_instant(
      max_epoch_nanoseconds(),
      time_zone: time_zone.utc(),
      calendar: calendar.iso_8601(),
    ),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime
// test262: test/built-ins/Temporal/ZonedDateTime/limits.js
pub fn zoned_date_time_from_instant_rejects_above_positive_limit_test() {
  assertions.is_error_with_context(
    "one nanosecond above positive limit",
    zoned_date_time.from_instant(
      bigi.add(max_epoch_nanoseconds(), bigi.from_int(1)),
      time_zone: time_zone.utc(),
      calendar: calendar.iso_8601(),
    ),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.compare
// test262: test/built-ins/Temporal/ZonedDateTime/compare/compares-exact-time-not-clock-time.js
pub fn zoned_date_time_compare_uses_exact_time_test() {
  let earlier = at(bigi.from_int(-1), time_zone.utc())
  let later =
    at(
      bigi.from_int(1),
      assertions.is_ok_with_context(
        "offset zone",
        time_zone.from_offset("+05:00"),
      ),
    )
  assertions.equal_with_context(
    "exact-time ordering",
    zoned_date_time.compare(earlier, later),
    Lt,
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-CALENDARID
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.calendarid
pub fn zoned_date_time_calendar_id_returns_iso_calendar_test() {
  assertions.equal_with_context(
    "calendar identifier",
    zoned_date_time.calendar_id(at(bigi.from_int(0), time_zone.utc())),
    "iso8601",
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-TIMEZONEID
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.timezoneid
pub fn zoned_date_time_time_zone_id_returns_fixed_offset_test() {
  let zone =
    assertions.is_ok_with_context(
      "fixed offset",
      time_zone.from_offset("+01:30"),
    )
  assertions.equal_with_context(
    "time-zone identifier",
    zoned_date_time.time_zone_id(at(bigi.from_int(0), zone)),
    "+01:30",
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-EPOCHMILLISECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.epochmilliseconds
pub fn zoned_date_time_epoch_milliseconds_floors_negative_fraction_test() {
  assertions.equal_with_context(
    "negative epoch milliseconds",
    zoned_date_time.epoch_milliseconds(at(bigi.from_int(-1), time_zone.utc())),
    -1,
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-EPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.epochnanoseconds
pub fn zoned_date_time_epoch_nanoseconds_is_exact_test() {
  assertions.equal_with_context(
    "epoch nanoseconds",
    zoned_date_time.epoch_nanoseconds(at(bigi.from_int(999), time_zone.utc())),
    bigi.from_int(999),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-OFFSETNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.offsetnanoseconds
pub fn zoned_date_time_offset_nanoseconds_returns_fixed_offset_test() {
  let zone =
    assertions.is_ok_with_context(
      "fixed offset",
      time_zone.from_offset("-02:30"),
    )
  assertions.equal_with_context(
    "offset nanoseconds",
    zoned_date_time.offset_nanoseconds(at(bigi.from_int(0), zone)),
    Ok(-9_000_000_000_000),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-OFFSET
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.offset
pub fn zoned_date_time_offset_returns_iso_string_test() {
  let zone =
    assertions.is_ok_with_context(
      "fixed offset",
      time_zone.from_offset("-02:30"),
    )
  assertions.equal_with_context(
    "ISO offset",
    zoned_date_time.offset(at(bigi.from_int(0), zone)),
    Ok("-02:30"),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-EQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.equals
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/equals/different-time-zone-not-equal.js
pub fn zoned_date_time_equal_includes_time_zone_test() {
  let offset =
    assertions.is_ok_with_context(
      "zero fixed offset",
      time_zone.from_offset("+00:00"),
    )
  assertions.equal_with_context(
    "same instant in distinct zones",
    zoned_date_time.equal(
      at(bigi.from_int(0), time_zone.utc()),
      at(bigi.from_int(0), offset),
    ),
    False,
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-TOINSTANT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.toinstant
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/toInstant/recent-date.js
pub fn zoned_date_time_to_instant_preserves_epoch_nanoseconds_test() {
  assertions.equal_with_context(
    "converted instant",
    zoned_date_time.to_instant(at(bigi.from_int(42), time_zone.utc())),
    bigi.from_int(42),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-CREATETEMPORALZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-createtemporalzoneddatetime
pub fn zoned_date_time_creation_retains_canonical_identifiers_test() {
  let value = at(bigi.from_int(0), time_zone.utc())
  assertions.equal_with_context(
    "canonical identifiers",
    #(zoned_date_time.time_zone_id(value), zoned_date_time.calendar_id(value)),
    #("UTC", "iso8601"),
  )
}
