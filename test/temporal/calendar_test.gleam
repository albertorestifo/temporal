import temporal
import temporal/calendar
import temporal/support/assertions

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendars
pub fn calendar_iso_8601_returns_canonical_id_test() {
  assertions.equal_with_context(
    "ISO calendar identifier",
    calendar.to_string(calendar.Iso8601),
    "iso8601",
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CANONICALIZECALENDAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-canonicalizecalendar
pub fn calendar_from_string_canonicalizes_case_test() {
  let value =
    assertions.is_ok_with_context(
      "case-insensitive ISO identifier",
      calendar.from_string("ISO8601"),
    )
  assertions.equal_with_context("canonical calendar", value, calendar.Iso8601)
}

// Requirement: TEMP-S12-SEC-AVAILABLECALENDARS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-availablecalendars
pub fn calendar_core_exposes_iso_calendar_test() {
  assertions.equal_with_context(
    "available core calendar",
    calendar.iso_8601(),
    calendar.Iso8601,
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-TOTEMPORALCALENDARIDENTIFIER
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-totemporalcalendaridentifier
pub fn calendar_from_string_rejects_unknown_calendar_test() {
  assertions.equal_with_context(
    "unsupported non-ISO calendar",
    calendar.from_string("hebrew"),
    Error(temporal.UnknownCalendar("hebrew")),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDAREQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarequals
pub fn calendar_equal_matches_canonical_identifiers_test() {
  let uppercase =
    assertions.is_ok_with_context(
      "uppercase ISO calendar",
      calendar.from_string("ISO8601"),
    )
  assertions.equal_with_context(
    "equivalent calendars",
    calendar.equal(calendar.iso_8601(), uppercase),
    True,
  )
}
