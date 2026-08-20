import gleam/option.{Some}
import gleam/order.{Lt}
import temporal
import temporal/calendar
import temporal/plain_date
import temporal/support/assertions
import temporal/support/plain_fixtures

fn fixture() {
  plain_date.fixture(year: 2026, month: 8, day: 20)
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate
// test262: test/built-ins/Temporal/PlainDate/basic.js
pub fn plain_date_new_accepts_iso_date_test() {
  assertions.is_ok_with_context(
    "valid ISO date",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: plain_fixtures.iso_calendar(),
      overflow: temporal.Reject,
    ),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.from
// test262: test/built-ins/Temporal/PlainDate/from/argument-string.js
pub fn plain_date_from_iso_8601_parses_date_test() {
  assertions.is_ok_with_context(
    "ISO date",
    plain_date.from_iso_8601("2026-08-20"),
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-YEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.year
// test262: test/built-ins/Temporal/PlainDate/prototype/year/basic.js
pub fn plain_date_year_returns_iso_year_test() {
  assertions.equal_with_context(
    "plain_date_year_returns_iso_year",
    plain_date.year(fixture()),
    2026,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-MONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.month
// test262: test/built-ins/Temporal/PlainDate/prototype/month/basic.js
pub fn plain_date_month_returns_iso_month_test() {
  assertions.equal_with_context(
    "plain_date_month_returns_iso_month",
    plain_date.month(fixture()),
    8,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-MONTHCODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.monthcode
// test262: test/built-ins/Temporal/PlainDate/prototype/monthCode/basic.js
pub fn plain_date_month_code_returns_iso_code_test() {
  assertions.equal_with_context(
    "plain_date_month_code_returns_iso_code",
    plain_date.month_code(fixture()),
    "M08",
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-DAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.day
// test262: test/built-ins/Temporal/PlainDate/prototype/day/basic.js
pub fn plain_date_day_returns_iso_day_test() {
  assertions.equal_with_context(
    "plain_date_day_returns_iso_day",
    plain_date.day(fixture()),
    20,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-CALENDARID
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.calendarid
// test262: test/built-ins/Temporal/PlainDate/prototype/calendarId/basic.js
pub fn plain_date_calendar_returns_iso8601_test() {
  assertions.equal_with_context(
    "ISO calendar",
    plain_date.calendar(fixture()),
    calendar.Iso8601,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-DAYOFWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.dayofweek
// test262: test/built-ins/Temporal/PlainDate/prototype/dayOfWeek/basic.js
pub fn plain_date_day_of_week_returns_iso_weekday_test() {
  assertions.equal_with_context(
    "plain_date_day_of_week_returns_iso_weekday",
    plain_date.day_of_week(fixture()),
    4,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-DAYOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.dayofyear
// test262: test/built-ins/Temporal/PlainDate/prototype/dayOfYear/basic.js
pub fn plain_date_day_of_year_returns_ordinal_test() {
  assertions.equal_with_context(
    "plain_date_day_of_year_returns_ordinal",
    plain_date.day_of_year(fixture()),
    232,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-WEEKOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.weekofyear
// test262: test/built-ins/Temporal/PlainDate/prototype/weekOfYear/basic.js
pub fn plain_date_week_of_year_returns_iso_week_test() {
  assertions.equal_with_context(
    "plain_date_week_of_year_returns_iso_week",
    plain_date.week_of_year(fixture()),
    Some(34),
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-YEAROFWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.yearofweek
// test262: test/built-ins/Temporal/PlainDate/prototype/yearOfWeek/basic.js
pub fn plain_date_year_of_week_returns_iso_year_test() {
  assertions.equal_with_context(
    "plain_date_year_of_week_returns_iso_year",
    plain_date.year_of_week(fixture()),
    Some(2026),
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-DAYSINWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.daysinweek
// test262: test/built-ins/Temporal/PlainDate/prototype/daysInWeek/basic.js
pub fn plain_date_days_in_week_returns_seven_test() {
  assertions.equal_with_context(
    "plain_date_days_in_week_returns_seven",
    plain_date.days_in_week(fixture()),
    7,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-DAYSINMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.daysinmonth
// test262: test/built-ins/Temporal/PlainDate/prototype/daysInMonth/basic.js
pub fn plain_date_days_in_month_returns_august_length_test() {
  assertions.equal_with_context(
    "plain_date_days_in_month_returns_august_length",
    plain_date.days_in_month(fixture()),
    31,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-DAYSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.daysinyear
// test262: test/built-ins/Temporal/PlainDate/prototype/daysInYear/basic.js
pub fn plain_date_days_in_year_returns_common_year_length_test() {
  assertions.equal_with_context(
    "plain_date_days_in_year_returns_common_year_length",
    plain_date.days_in_year(fixture()),
    365,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-MONTHSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.monthsinyear
// test262: test/built-ins/Temporal/PlainDate/prototype/monthsInYear/basic.js
pub fn plain_date_months_in_year_returns_twelve_test() {
  assertions.equal_with_context(
    "plain_date_months_in_year_returns_twelve",
    plain_date.months_in_year(fixture()),
    12,
  )
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-INLEAPYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.inleapyear
// test262: test/built-ins/Temporal/PlainDate/prototype/inLeapYear/basic.js
pub fn plain_date_in_leap_year_returns_false_test() {
  assertions.equal_with_context(
    "plain_date_in_leap_year_returns_false",
    plain_date.in_leap_year(fixture()),
    False,
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.compare
// test262: test/built-ins/Temporal/PlainDate/compare/basic.js
pub fn plain_date_compare_orders_iso_dates_test() {
  let later = plain_date.fixture(year: 2026, month: 8, day: 21)
  assertions.equal_with_context(
    "date order",
    plain_date.compare(fixture(), later),
    Lt,
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-EQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.equals
// test262: test/built-ins/Temporal/PlainDate/prototype/equals/basic.js
pub fn plain_date_equal_matches_same_date_test() {
  assertions.equal_with_context(
    "same date",
    plain_date.equal(fixture(), fixture()),
    True,
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-ADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.add
// test262: test/built-ins/Temporal/PlainDate/prototype/add/basic.js
pub fn plain_date_add_applies_date_duration_test() {
  assertions.is_ok_with_context(
    "add",
    plain_date.add(fixture(), plain_fixtures.one_day(), temporal.Reject),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-SUBTRACT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.subtract
// test262: test/built-ins/Temporal/PlainDate/prototype/subtract/basic.js
pub fn plain_date_subtract_applies_date_duration_test() {
  assertions.is_ok_with_context(
    "subtract",
    plain_date.subtract(fixture(), plain_fixtures.one_day(), temporal.Reject),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-UNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.until
// test262: test/built-ins/Temporal/PlainDate/prototype/until/basic.js
pub fn plain_date_until_returns_duration_test() {
  assertions.is_ok_with_context(
    "until",
    plain_date.until(fixture(), fixture(), plain_fixtures.difference_options()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-SINCE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.since
// test262: test/built-ins/Temporal/PlainDate/prototype/since/basic.js
pub fn plain_date_since_returns_duration_test() {
  assertions.is_ok_with_context(
    "since",
    plain_date.since(fixture(), fixture(), plain_fixtures.difference_options()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.tostring
// test262: test/built-ins/Temporal/PlainDate/prototype/toString/basic.js
pub fn plain_date_to_iso_8601_formats_date_test() {
  assertions.equal_with_context(
    "ISO date",
    plain_date.to_iso_8601(fixture()),
    "2026-08-20",
  )
}
