import gleam/option.{Some}
import gleam/order.{Lt}
import temporal
import temporal/calendar
import temporal/duration
import temporal/plain_date_time
import temporal/support/assertions
import temporal/support/plain_fixtures

fn fixture() {
  let assert Ok(value) =
    plain_date_time.from_iso_8601("2026-08-20T12:34:56.123456789")
  value
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime
// test262: test/built-ins/Temporal/PlainDateTime/basic.js
pub fn plain_date_time_new_accepts_iso_value_test() {
  assertions.is_ok_with_context(
    "valid date-time",
    plain_date_time.new(
      year: 2026,
      month: 8,
      day: 20,
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      calendar: plain_fixtures.iso_calendar(),
      overflow: temporal.Reject,
    ),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.from
// test262: test/built-ins/Temporal/PlainDateTime/from/argument-string.js
pub fn plain_date_time_from_iso_8601_parses_value_test() {
  assertions.is_ok_with_context(
    "ISO date-time",
    plain_date_time.from_iso_8601("2026-08-20T12:34:56.123456789"),
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-YEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.year
// test262: test/built-ins/Temporal/PlainDateTime/prototype/year/basic.js
pub fn plain_date_time_year_returns_iso_value_test() {
  assertions.equal_with_context("year", plain_date_time.year(fixture()), 2026)
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-MONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.month
// test262: test/built-ins/Temporal/PlainDateTime/prototype/month/basic.js
pub fn plain_date_time_month_returns_iso_value_test() {
  assertions.equal_with_context("month", plain_date_time.month(fixture()), 8)
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-MONTHCODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.monthcode
// test262: test/built-ins/Temporal/PlainDateTime/prototype/monthcode/basic.js
pub fn plain_date_time_month_code_returns_iso_value_test() {
  assertions.equal_with_context(
    "month_code",
    plain_date_time.month_code(fixture()),
    "M08",
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-DAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.day
// test262: test/built-ins/Temporal/PlainDateTime/prototype/day/basic.js
pub fn plain_date_time_day_returns_iso_value_test() {
  assertions.equal_with_context("day", plain_date_time.day(fixture()), 20)
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-HOUR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.hour
// test262: test/built-ins/Temporal/PlainDateTime/prototype/hour/basic.js
pub fn plain_date_time_hour_returns_iso_value_test() {
  assertions.equal_with_context("hour", plain_date_time.hour(fixture()), 12)
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-MINUTE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.minute
// test262: test/built-ins/Temporal/PlainDateTime/prototype/minute/basic.js
pub fn plain_date_time_minute_returns_iso_value_test() {
  assertions.equal_with_context("minute", plain_date_time.minute(fixture()), 34)
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-SECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.second
// test262: test/built-ins/Temporal/PlainDateTime/prototype/second/basic.js
pub fn plain_date_time_second_returns_iso_value_test() {
  assertions.equal_with_context("second", plain_date_time.second(fixture()), 56)
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-MILLISECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.millisecond
// test262: test/built-ins/Temporal/PlainDateTime/prototype/millisecond/basic.js
pub fn plain_date_time_millisecond_returns_iso_value_test() {
  assertions.equal_with_context(
    "millisecond",
    plain_date_time.millisecond(fixture()),
    123,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-MICROSECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.microsecond
// test262: test/built-ins/Temporal/PlainDateTime/prototype/microsecond/basic.js
pub fn plain_date_time_microsecond_returns_iso_value_test() {
  assertions.equal_with_context(
    "microsecond",
    plain_date_time.microsecond(fixture()),
    456,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-NANOSECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.nanosecond
// test262: test/built-ins/Temporal/PlainDateTime/prototype/nanosecond/basic.js
pub fn plain_date_time_nanosecond_returns_iso_value_test() {
  assertions.equal_with_context(
    "nanosecond",
    plain_date_time.nanosecond(fixture()),
    789,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-CALENDARID
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.calendarid
// test262: test/built-ins/Temporal/PlainDateTime/prototype/calendarid/basic.js
pub fn plain_date_time_calendar_returns_iso_value_test() {
  assertions.equal_with_context(
    "ISO calendar",
    plain_date_time.calendar(fixture()),
    calendar.Iso8601,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-DAYOFWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.dayofweek
// test262: test/built-ins/Temporal/PlainDateTime/prototype/dayofweek/basic.js
pub fn plain_date_time_day_of_week_returns_iso_value_test() {
  assertions.equal_with_context(
    "day_of_week",
    plain_date_time.day_of_week(fixture()),
    4,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-DAYOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.dayofyear
// test262: test/built-ins/Temporal/PlainDateTime/prototype/dayofyear/basic.js
pub fn plain_date_time_day_of_year_returns_iso_value_test() {
  assertions.equal_with_context(
    "day_of_year",
    plain_date_time.day_of_year(fixture()),
    232,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-WEEKOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.weekofyear
// test262: test/built-ins/Temporal/PlainDateTime/prototype/weekofyear/basic.js
pub fn plain_date_time_week_of_year_returns_iso_value_test() {
  assertions.equal_with_context(
    "week_of_year",
    plain_date_time.week_of_year(fixture()),
    Some(34),
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-YEAROFWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.yearofweek
// test262: test/built-ins/Temporal/PlainDateTime/prototype/yearofweek/basic.js
pub fn plain_date_time_year_of_week_returns_iso_value_test() {
  assertions.equal_with_context(
    "year_of_week",
    plain_date_time.year_of_week(fixture()),
    Some(2026),
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-DAYSINWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.daysinweek
// test262: test/built-ins/Temporal/PlainDateTime/prototype/daysinweek/basic.js
pub fn plain_date_time_days_in_week_returns_iso_value_test() {
  assertions.equal_with_context(
    "days_in_week",
    plain_date_time.days_in_week(fixture()),
    7,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-DAYSINMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.daysinmonth
// test262: test/built-ins/Temporal/PlainDateTime/prototype/daysinmonth/basic.js
pub fn plain_date_time_days_in_month_returns_iso_value_test() {
  assertions.equal_with_context(
    "days_in_month",
    plain_date_time.days_in_month(fixture()),
    31,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-DAYSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.daysinyear
// test262: test/built-ins/Temporal/PlainDateTime/prototype/daysinyear/basic.js
pub fn plain_date_time_days_in_year_returns_iso_value_test() {
  assertions.equal_with_context(
    "days_in_year",
    plain_date_time.days_in_year(fixture()),
    365,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-MONTHSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.monthsinyear
// test262: test/built-ins/Temporal/PlainDateTime/prototype/monthsinyear/basic.js
pub fn plain_date_time_months_in_year_returns_iso_value_test() {
  assertions.equal_with_context(
    "months_in_year",
    plain_date_time.months_in_year(fixture()),
    12,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-INLEAPYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.inleapyear
// test262: test/built-ins/Temporal/PlainDateTime/prototype/inleapyear/basic.js
pub fn plain_date_time_in_leap_year_returns_iso_value_test() {
  assertions.equal_with_context(
    "in_leap_year",
    plain_date_time.in_leap_year(fixture()),
    False,
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.compare
// test262: test/built-ins/Temporal/PlainDateTime/compare/basic.js
pub fn plain_date_time_compare_orders_iso_fields_test() {
  let assert Ok(later) = plain_date_time.from_iso_8601("2026-08-20T13:00")
  assertions.equal_with_context(
    "date-time order",
    plain_date_time.compare(fixture(), later),
    Lt,
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-EQUALS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.equals
// test262: test/built-ins/Temporal/PlainDateTime/prototype/equals/basic.js
pub fn plain_date_time_equal_matches_same_value_test() {
  assertions.equal_with_context(
    "same date-time",
    plain_date_time.equal(fixture(), fixture()),
    True,
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-ADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.add
// test262: test/built-ins/Temporal/PlainDateTime/prototype/add/basic.js
pub fn plain_date_time_add_applies_duration_test() {
  assertions.is_ok_with_context(
    "add",
    plain_date_time.add(fixture(), plain_fixtures.one_day(), temporal.Reject),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-SUBTRACT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.subtract
// test262: test/built-ins/Temporal/PlainDateTime/prototype/subtract/basic.js
pub fn plain_date_time_subtract_applies_duration_test() {
  assertions.is_ok_with_context(
    "subtract",
    plain_date_time.subtract(
      fixture(),
      plain_fixtures.one_day(),
      temporal.Reject,
    ),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-UNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.until
// test262: test/built-ins/Temporal/PlainDateTime/prototype/until/basic.js
pub fn plain_date_time_until_returns_duration_test() {
  assertions.is_ok_with_context(
    "until",
    plain_date_time.until(
      fixture(),
      fixture(),
      plain_fixtures.difference_options(),
    ),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-SINCE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.since
// test262: test/built-ins/Temporal/PlainDateTime/prototype/since/basic.js
pub fn plain_date_time_since_returns_duration_test() {
  assertions.is_ok_with_context(
    "since",
    plain_date_time.since(
      fixture(),
      fixture(),
      plain_fixtures.difference_options(),
    ),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-ROUND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.round
// test262: test/built-ins/Temporal/PlainDateTime/prototype/round/roundingincrement-minutes.js
pub fn plain_date_time_round_uses_typed_unit_test() {
  assertions.is_ok_with_context(
    "round",
    plain_date_time.round(fixture(), duration.Minute, 15, temporal.HalfExpand),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.tostring
// test262: test/built-ins/Temporal/PlainDateTime/prototype/toString/basic.js
pub fn plain_date_time_to_iso_8601_formats_value_test() {
  assertions.equal_with_context(
    "ISO date-time",
    plain_date_time.to_iso_8601(fixture()),
    "2026-08-20T12:34:56.123456789",
  )
}
