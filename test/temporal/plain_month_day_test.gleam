import temporal
import temporal/calendar
import temporal/plain_month_day
import temporal/support/assertions
import temporal/support/plain_fixtures

fn fixture() {
  plain_month_day.fixture(month: 8, day: 20, reference_year: 1972)
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal.plainmonthday
// test262: test/built-ins/Temporal/PlainMonthDay/basic.js
pub fn plain_month_day_new_accepts_iso_value_test() {
  assertions.is_ok_with_context(
    "valid month-day",
    plain_month_day.new(
      month: 8,
      day: 20,
      reference_year: 1972,
      calendar: plain_fixtures.iso_calendar(),
      overflow: temporal.Reject,
    ),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal.plainmonthday.from
// test262: test/built-ins/Temporal/PlainMonthDay/from/basic.js
pub fn plain_month_day_from_iso_8601_parses_value_test() {
  assertions.is_ok_with_context(
    "ISO month-day",
    plain_month_day.from_iso_8601("08-20"),
  )
}

// Requirement: TEMP-S10-SEC-GET-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-MONTHCODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-get-temporal.plainmonthday.prototype.monthcode
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/monthCode/basic.js
pub fn plain_month_day_month_code_returns_iso_code_test() {
  assertions.equal_with_context(
    "plain_month_day_month_code_returns_iso_code",
    plain_month_day.month_code(fixture()),
    "M08",
  )
}

// Requirement: TEMP-S10-SEC-GET-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-DAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-get-temporal.plainmonthday.prototype.day
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/day/basic.js
pub fn plain_month_day_day_returns_day_test() {
  assertions.equal_with_context(
    "plain_month_day_day_returns_day",
    plain_month_day.day(fixture()),
    20,
  )
}

// Requirement: TEMP-S10-SEC-GET-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-CALENDARID
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-get-temporal.plainmonthday.prototype.calendarid
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/calendarId/basic.js
pub fn plain_month_day_calendar_returns_iso8601_test() {
  assertions.equal_with_context(
    "ISO calendar",
    plain_month_day.calendar(fixture()),
    calendar.Iso8601,
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-EQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal.plainmonthday.prototype.equals
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/equals/basic.js
pub fn plain_month_day_equal_matches_same_value_test() {
  assertions.equal_with_context(
    "same month-day",
    plain_month_day.equal(fixture(), fixture()),
    True,
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal.plainmonthday.prototype.tostring
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/toString/basic.js
pub fn plain_month_day_to_iso_8601_formats_value_test() {
  assertions.equal_with_context(
    "ISO month-day",
    plain_month_day.to_iso_8601(fixture()),
    "08-20",
  )
}
