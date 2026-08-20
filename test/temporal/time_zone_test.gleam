import bigi
import temporal
import temporal/support/assertions
import temporal/time_zone

// Requirement: TEMP-S11-SEC-TEMPORAL-TIMEZONES
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-timezones
pub fn time_zone_utc_returns_canonical_id_test() {
  assertions.equal_with_context(
    "UTC identifier",
    time_zone.to_string(time_zone.utc()),
    "UTC",
  )
}

// Requirement: TEMP-S11-SEC-GETAVAILABLENAMEDTIMEZONEIDENTIFIER
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-getavailablenamedtimezoneidentifier
pub fn time_zone_named_identifier_requires_provider_test() {
  assertions.equal_with_context(
    "named zone without provider",
    time_zone.from_string("Europe/Madrid"),
    Error(temporal.UnknownTimeZone("Europe/Madrid")),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-FORMATOFFSETTIMEZONEIDENTIFIER
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-formatoffsettimezoneidentifier
pub fn time_zone_from_offset_preserves_canonical_offset_test() {
  let value =
    assertions.is_ok_with_context(
      "positive fixed offset",
      time_zone.from_offset("+01:30"),
    )
  assertions.equal_with_context(
    "canonical fixed offset",
    time_zone.to_string(value),
    "+01:30",
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-FORMATUTCOFFSETNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-formatutcoffsetnanoseconds
pub fn time_zone_offset_iso_8601_formats_negative_offset_test() {
  let value =
    assertions.is_ok_with_context(
      "negative fixed offset",
      time_zone.from_offset("-05:45"),
    )
  assertions.equal_with_context(
    "negative ISO offset",
    time_zone.offset_iso_8601_for(value, bigi.from_int(0)),
    Ok("-05:45"),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-TOTEMPORALTIMEZONEIDENTIFIER
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-totemporaltimezoneidentifier
pub fn time_zone_from_string_canonicalizes_utc_case_test() {
  let value =
    assertions.is_ok_with_context(
      "case-insensitive UTC",
      time_zone.from_string("utc"),
    )
  assertions.equal_with_context("canonical UTC", value, time_zone.utc())
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETOFFSETNANOSECONDSFOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getoffsetnanosecondsfor
pub fn time_zone_offset_nanoseconds_is_fixed_for_instant_test() {
  let value =
    assertions.is_ok_with_context(
      "positive fixed offset",
      time_zone.from_offset("+01:30"),
    )
  assertions.equal_with_context(
    "fixed offset nanoseconds",
    time_zone.offset_nanoseconds_for(value, bigi.from_int(123_456_789)),
    Ok(5_400_000_000_000),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-TIMEZONEEQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-timezoneequals
pub fn time_zone_equal_compares_canonical_identifiers_test() {
  let first =
    assertions.is_ok_with_context(
      "first offset",
      time_zone.from_offset("+02:00"),
    )
  let second =
    assertions.is_ok_with_context("second offset", time_zone.from_id("+02:00"))
  assertions.equal_with_context(
    "equivalent fixed offsets",
    time_zone.equal(first, second),
    True,
  )
}

// Requirement: TEMP-S11-SEC-PARSETIMEZONEIDENTIFIER
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-parsetimezoneidentifier
pub fn time_zone_from_offset_rejects_out_of_range_value_test() {
  assertions.equal_with_context(
    "24-hour offset",
    time_zone.from_offset("+24:00"),
    Error(temporal.InvalidIsoString("+24:00")),
  )
}
