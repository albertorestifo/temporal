import gleam/order.{Lt}
import temporal
import temporal/calendar
import temporal/plain_year_month
import temporal/support/assertions
import temporal/support/plain_fixtures

fn fixture() {
  plain_year_month.fixture(year: 2026, month: 8, reference_day: 1)
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth
// test262: test/built-ins/Temporal/PlainYearMonth/basic.js
pub fn plain_year_month_new_accepts_iso_value_test() {
  assertions.is_ok_with_context(
    "valid year-month",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: plain_fixtures.iso_calendar(),
      overflow: temporal.Reject,
    ),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.from
// test262: test/built-ins/Temporal/PlainYearMonth/from/argument-string.js
pub fn plain_year_month_from_iso_8601_parses_value_test() {
  assertions.is_ok_with_context(
    "ISO year-month",
    plain_year_month.from_iso_8601("2026-08"),
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-YEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.year
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/year/basic.js
pub fn plain_year_month_year_returns_year_test() {
  assertions.equal_with_context(
    "plain_year_month_year_returns_year",
    plain_year_month.year(fixture()),
    2026,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-MONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.month
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/month/basic.js
pub fn plain_year_month_month_returns_month_test() {
  assertions.equal_with_context(
    "plain_year_month_month_returns_month",
    plain_year_month.month(fixture()),
    8,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-MONTHCODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.monthcode
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/monthCode/basic.js
pub fn plain_year_month_month_code_returns_iso_code_test() {
  assertions.equal_with_context(
    "plain_year_month_month_code_returns_iso_code",
    plain_year_month.month_code(fixture()),
    "M08",
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-CALENDARID
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.calendarid
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/calendarId/basic.js
pub fn plain_year_month_calendar_returns_iso8601_test() {
  assertions.equal_with_context(
    "ISO calendar",
    plain_year_month.calendar(fixture()),
    calendar.Iso8601,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-DAYSINMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.daysinmonth
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/daysInMonth/basic.js
pub fn plain_year_month_days_in_month_returns_august_length_test() {
  assertions.equal_with_context(
    "plain_year_month_days_in_month_returns_august_length",
    plain_year_month.days_in_month(fixture()),
    31,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-DAYSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.daysinyear
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/daysInYear/basic.js
pub fn plain_year_month_days_in_year_returns_common_length_test() {
  assertions.equal_with_context(
    "plain_year_month_days_in_year_returns_common_length",
    plain_year_month.days_in_year(fixture()),
    365,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-MONTHSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.monthsinyear
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/monthsInYear/basic.js
pub fn plain_year_month_months_in_year_returns_twelve_test() {
  assertions.equal_with_context(
    "plain_year_month_months_in_year_returns_twelve",
    plain_year_month.months_in_year(fixture()),
    12,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-INLEAPYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.inleapyear
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/inLeapYear/basic.js
pub fn plain_year_month_in_leap_year_returns_false_test() {
  assertions.equal_with_context(
    "plain_year_month_in_leap_year_returns_false",
    plain_year_month.in_leap_year(fixture()),
    False,
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.compare
// test262: test/built-ins/Temporal/PlainYearMonth/compare/basic.js
pub fn plain_year_month_compare_orders_iso_fields_test() {
  let later = plain_year_month.fixture(year: 2026, month: 9, reference_day: 1)
  assertions.equal_with_context(
    "year-month order",
    plain_year_month.compare(fixture(), later),
    Lt,
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-EQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.equals
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/equals/basic.js
pub fn plain_year_month_equal_matches_same_value_test() {
  assertions.equal_with_context(
    "same year-month",
    plain_year_month.equal(fixture(), fixture()),
    True,
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-ADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.add
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/add/basic.js
pub fn plain_year_month_add_applies_duration_test() {
  assertions.is_ok_with_context(
    "add",
    plain_year_month.add(fixture(), plain_fixtures.one_day(), temporal.Reject),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-SUBTRACT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.subtract
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/subtract/basic.js
pub fn plain_year_month_subtract_applies_duration_test() {
  assertions.is_ok_with_context(
    "subtract",
    plain_year_month.subtract(
      fixture(),
      plain_fixtures.one_day(),
      temporal.Reject,
    ),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-UNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.until
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/until/basic.js
pub fn plain_year_month_until_returns_duration_test() {
  assertions.is_ok_with_context(
    "until",
    plain_year_month.until(
      fixture(),
      fixture(),
      plain_fixtures.difference_options(),
    ),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-SINCE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.since
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/since/basic.js
pub fn plain_year_month_since_returns_duration_test() {
  assertions.is_ok_with_context(
    "since",
    plain_year_month.since(
      fixture(),
      fixture(),
      plain_fixtures.difference_options(),
    ),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.tostring
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/toString/year-format.js
pub fn plain_year_month_to_iso_8601_formats_value_test() {
  assertions.equal_with_context(
    "ISO year-month",
    plain_year_month.to_iso_8601(fixture()),
    "2026-08",
  )
}
