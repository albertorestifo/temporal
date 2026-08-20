import bigi
import gleam/option.{Some}
import temporal
import temporal/calendar
import temporal/duration.{type Duration, Duration}
import temporal/instant
import temporal/plain_date
import temporal/plain_date_time
import temporal/plain_month_day
import temporal/plain_time
import temporal/plain_year_month
import temporal/support/assertions
import temporal/time_zone
import temporal/zoned_date_time

fn epoch() -> instant.Instant {
  assertions.is_ok_with_context(
    "epoch fixture",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
  )
}

fn zoned_fixture() -> zoned_date_time.ZonedDateTime {
  assertions.is_ok_with_context(
    "UTC zoned fixture",
    zoned_date_time.from_instant(epoch(), time_zone.utc(), calendar.Iso8601),
  )
}

fn date_fixture() -> plain_date.PlainDate {
  plain_date.fixture(year: 1970, month: 1, day: 1)
}

fn time_fixture() -> plain_time.PlainTime {
  plain_time.fixture(
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
    nanosecond: 0,
  )
}

fn date_time_fixture() -> plain_date_time.PlainDateTime {
  plain_date_time.fixture(date: date_fixture(), time: time_fixture())
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

fn difference_options() -> duration.DifferenceOptions {
  duration.DifferenceOptions(
    largest_unit: duration.Day,
    smallest_unit: duration.Nanosecond,
    rounding_increment: 1,
    rounding_mode: temporal.Trunc,
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-zoneddatetime-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_zoneddatetime_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned construction",
    zoned_date_time.from_instant(epoch(), time_zone.utc(), calendar.Iso8601),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.from
// test262: test/built-ins/Temporal/ZonedDateTime/from/argument-object.js
pub fn temporal_zoneddatetime_from_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned parsing",
    zoned_date_time.from_iso_8601("1970-01-01T00:00:00+00:00[UTC]"),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-YEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.year
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/year/basic.js
pub fn get_temporal_zoneddatetime_prototype_year_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned year",
    zoned_date_time.year(zoned_fixture()),
    Ok(1970),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-MONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.month
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/month/basic.js
pub fn get_temporal_zoneddatetime_prototype_month_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned month",
    zoned_date_time.month(zoned_fixture()),
    Ok(1),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-MONTHCODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.monthcode
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/monthCode/basic.js
pub fn get_temporal_zoneddatetime_prototype_monthcode_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned month_code",
    zoned_date_time.month_code(zoned_fixture()),
    Ok("M01"),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-DAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.day
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/day/balance-negative-time-units.js
pub fn get_temporal_zoneddatetime_prototype_day_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned day",
    zoned_date_time.day(zoned_fixture()),
    Ok(1),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-HOUR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.hour
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/hour/balance-negative-time-units.js
pub fn get_temporal_zoneddatetime_prototype_hour_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned hour",
    zoned_date_time.hour(zoned_fixture()),
    Ok(0),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-MINUTE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.minute
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/minute/balance-negative-time-units.js
pub fn get_temporal_zoneddatetime_prototype_minute_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned minute",
    zoned_date_time.minute(zoned_fixture()),
    Ok(0),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-SECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.second
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/second/balance-negative-time-units.js
pub fn get_temporal_zoneddatetime_prototype_second_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned second",
    zoned_date_time.second(zoned_fixture()),
    Ok(0),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-MILLISECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.millisecond
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/millisecond/balance-negative-time-units.js
pub fn get_temporal_zoneddatetime_prototype_millisecond_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned millisecond",
    zoned_date_time.millisecond(zoned_fixture()),
    Ok(0),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-MICROSECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.microsecond
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/microsecond/balance-negative-time-units.js
pub fn get_temporal_zoneddatetime_prototype_microsecond_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned microsecond",
    zoned_date_time.microsecond(zoned_fixture()),
    Ok(0),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-NANOSECOND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.nanosecond
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/nanosecond/basic.js
pub fn get_temporal_zoneddatetime_prototype_nanosecond_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned nanosecond",
    zoned_date_time.nanosecond(zoned_fixture()),
    Ok(0),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-DAYOFWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.dayofweek
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/dayOfWeek/basic.js
pub fn get_temporal_zoneddatetime_prototype_dayofweek_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned day_of_week",
    zoned_date_time.day_of_week(zoned_fixture()),
    Ok(4),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-DAYOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.dayofyear
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/dayOfYear/basic.js
pub fn get_temporal_zoneddatetime_prototype_dayofyear_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned day_of_year",
    zoned_date_time.day_of_year(zoned_fixture()),
    Ok(1),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-WEEKOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.weekofyear
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/weekOfYear/basic.js
pub fn get_temporal_zoneddatetime_prototype_weekofyear_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned week_of_year",
    zoned_date_time.week_of_year(zoned_fixture()),
    Ok(Some(1)),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-YEAROFWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.yearofweek
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/yearOfWeek/basic.js
pub fn get_temporal_zoneddatetime_prototype_yearofweek_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned year_of_week",
    zoned_date_time.year_of_week(zoned_fixture()),
    Ok(Some(1970)),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-HOURSINDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.hoursinday
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/hoursInDay/basic.js
pub fn get_temporal_zoneddatetime_prototype_hoursinday_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC hours in day",
    zoned_date_time.hours_in_day(zoned_fixture()),
    Ok(24.0),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-DAYSINWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.daysinweek
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/daysInWeek/basic.js
pub fn get_temporal_zoneddatetime_prototype_daysinweek_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned days_in_week",
    zoned_date_time.days_in_week(zoned_fixture()),
    Ok(7),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-DAYSINMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.daysinmonth
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/daysInMonth/basic.js
pub fn get_temporal_zoneddatetime_prototype_daysinmonth_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned days_in_month",
    zoned_date_time.days_in_month(zoned_fixture()),
    Ok(31),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-DAYSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.daysinyear
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/daysInYear/basic.js
pub fn get_temporal_zoneddatetime_prototype_daysinyear_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned days_in_year",
    zoned_date_time.days_in_year(zoned_fixture()),
    Ok(365),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-MONTHSINYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.monthsinyear
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/monthsInYear/basic.js
pub fn get_temporal_zoneddatetime_prototype_monthsinyear_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned months_in_year",
    zoned_date_time.months_in_year(zoned_fixture()),
    Ok(12),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-INLEAPYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.inleapyear
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/inLeapYear/basic.js
pub fn get_temporal_zoneddatetime_prototype_inleapyear_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned in_leap_year",
    zoned_date_time.in_leap_year(zoned_fixture()),
    Ok(False),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-ADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.add
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/add/add-duration.js
pub fn temporal_zoneddatetime_prototype_add_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned addition",
    zoned_date_time.add(zoned_fixture(), zero_duration(), temporal.Constrain),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-SUBTRACT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.subtract
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/subtract/argument-duration-max-plus-min-date.js
pub fn temporal_zoneddatetime_prototype_subtract_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned subtraction",
    zoned_date_time.subtract(
      zoned_fixture(),
      zero_duration(),
      temporal.Constrain,
    ),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-UNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.until
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/until/argument-at-limits.js
pub fn temporal_zoneddatetime_prototype_until_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned difference",
    zoned_date_time.until(
      zoned_fixture(),
      zoned_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-SINCE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.since
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/since/argument-at-limits.js
pub fn temporal_zoneddatetime_prototype_since_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned difference",
    zoned_date_time.until(
      zoned_fixture(),
      zoned_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-ROUND
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.round
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/round/branding.js
pub fn temporal_zoneddatetime_prototype_round_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned rounding",
    zoned_date_time.round(
      zoned_fixture(),
      duration.Second,
      1,
      temporal.HalfExpand,
    ),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-TOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.tostring
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/toString/balance-negative-time-units.js
pub fn temporal_zoneddatetime_prototype_tostring_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned ISO serialization",
    zoned_date_time.to_iso_8601(zoned_fixture()),
    Ok("1970-01-01T00:00:00+00:00[UTC]"),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.tojson
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/toJSON/balance-negative-time-units.js
pub fn temporal_zoneddatetime_prototype_tojson_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned ISO serialization",
    zoned_date_time.to_iso_8601(zoned_fixture()),
    Ok("1970-01-01T00:00:00+00:00[UTC]"),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-STARTOFDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.startofday
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/startOfDay/basic.js
pub fn temporal_zoneddatetime_prototype_startofday_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned start of day",
    zoned_date_time.start_of_day(zoned_fixture()),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-TOPLAINDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.toplaindate
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/toPlainDate/basic.js
pub fn temporal_zoneddatetime_prototype_toplaindate_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned local date-time",
    zoned_date_time.to_plain_date_time(zoned_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-TOPLAINTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.toplaintime
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/toPlainTime/balance-negative-time-units.js
pub fn temporal_zoneddatetime_prototype_toplaintime_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned local date-time",
    zoned_date_time.to_plain_date_time(zoned_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-TOPLAINDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.toplaindatetime
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/toPlainDateTime/balance-negative-time-units.js
pub fn temporal_zoneddatetime_prototype_toplaindatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned local date-time",
    zoned_date_time.to_plain_date_time(zoned_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-zoneddatetime-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_zoneddatetime_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "local date-time resolution",
    zoned_date_time.from_plain_date_time(
      date_time_fixture(),
      time_zone.utc(),
      temporal.Compatible,
    ),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-INTERPRETISODATETIMEOFFSET
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-interpretisodatetimeoffset
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_interpretisodatetimeoffset_planned_requirement_test() {
  assertions.equal_with_context(
    "local date-time resolution",
    zoned_date_time.from_plain_date_time(
      date_time_fixture(),
      time_zone.utc(),
      temporal.Compatible,
    ),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-TOTEMPORALZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-totemporalzoneddatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_totemporalzoneddatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned parsing",
    zoned_date_time.from_iso_8601("1970-01-01T00:00:00+00:00[UTC]"),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-TEMPORALZONEDDATETIMETOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-temporalzoneddatetimetostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_temporalzoneddatetimetostring_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned ISO serialization",
    zoned_date_time.to_iso_8601(zoned_fixture()),
    Ok("1970-01-01T00:00:00+00:00[UTC]"),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ADDZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-addzoneddatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_addzoneddatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned addition",
    zoned_date_time.add(zoned_fixture(), zero_duration(), temporal.Constrain),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-DIFFERENCEZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-differencezoneddatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_differencezoneddatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned difference",
    zoned_date_time.until(
      zoned_fixture(),
      zoned_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-DIFFERENCEZONEDDATETIMEWITHROUNDING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-differencezoneddatetimewithrounding
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_differencezoneddatetimewithrounding_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned difference",
    zoned_date_time.until(
      zoned_fixture(),
      zoned_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-DIFFERENCEZONEDDATETIMEWITHTOTAL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-differencezoneddatetimewithtotal
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_differencezoneddatetimewithtotal_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned difference",
    zoned_date_time.until(
      zoned_fixture(),
      zoned_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-DIFFERENCETEMPORALZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-differencetemporalzoneddatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_differencetemporalzoneddatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned difference",
    zoned_date_time.until(
      zoned_fixture(),
      zoned_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ADDDURATIONTOZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal-adddurationtozoneddatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-exact-time
pub fn temporal_adddurationtozoneddatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "zoned addition",
    zoned_date_time.add(zoned_fixture(), zero_duration(), temporal.Constrain),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-TIMEZONE-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-timezone-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_timezone_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC ISO date-time conversion",
    zoned_date_time.to_plain_date_time(zoned_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETISOPARTSFROMEPOCH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getisopartsfromepoch
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_getisopartsfromepoch_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC ISO date-time conversion",
    zoned_date_time.to_plain_date_time(zoned_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-FORMATDATETIMEUTCOFFSETROUNDED
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-formatdatetimeutcoffsetrounded
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_formatdatetimeutcoffsetrounded_planned_requirement_test() {
  assertions.equal_with_context(
    "formatted UTC offset",
    time_zone.offset_iso_8601_for(time_zone.utc(), epoch()),
    Ok("+00:00"),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETISODATETIMEFOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getisodatetimefor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_getisodatetimefor_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC ISO date-time conversion",
    zoned_date_time.to_plain_date_time(zoned_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETEPOCHNANOSECONDSFOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getepochnanosecondsfor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_getepochnanosecondsfor_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC local resolution",
    zoned_date_time.from_plain_date_time(
      date_time_fixture(),
      time_zone.utc(),
      temporal.Compatible,
    ),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-DISAMBIGUATEPOSSIBLEEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-disambiguatepossibleepochnanoseconds
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_disambiguatepossibleepochnanoseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC local resolution",
    zoned_date_time.from_plain_date_time(
      date_time_fixture(),
      time_zone.utc(),
      temporal.Compatible,
    ),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETPOSSIBLEEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getpossibleepochnanoseconds
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_getpossibleepochnanoseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC local resolution",
    zoned_date_time.from_plain_date_time(
      date_time_fixture(),
      time_zone.utc(),
      temporal.Compatible,
    ),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETSTARTOFDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getstartofday
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#preserving-local-time
pub fn temporal_getstartofday_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC start of day",
    zoned_date_time.start_of_day(zoned_fixture()),
    Ok(zoned_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-CALENDAR-TYPES
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-calendar-types
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn calendar_types_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar identifier",
    calendar.to_string(calendar.Iso8601),
    "iso8601",
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-MONTH-CODES
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-month-codes
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_month_codes_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO month code",
    plain_date.month_code(date_fixture()),
    "M01",
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-PARSEMONTHCODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-parsemonthcode
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_parsemonthcode_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO month code",
    plain_date.month_code(date_fixture()),
    "M01",
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CREATEMONTHCODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-createmonthcode
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_createmonthcode_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO month code",
    plain_date.month_code(date_fixture()),
    "M01",
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDAR-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendar-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendar_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date fields",
    plain_date.new(
      year: 1970,
      month: 1,
      day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDAR-DATE-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendar-date-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendar_date_records_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date fields",
    plain_date.new(
      year: 1970,
      month: 1,
      day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDAR-FIELDS-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendar-fields-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendar_fields_records_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date fields",
    plain_date.new(
      year: 1970,
      month: 1,
      day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARDATEADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendardateadd
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendardateadd_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date addition",
    plain_date.add(date_fixture(), zero_duration(), temporal.Constrain),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARDATEUNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendardateuntil
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendardateuntil_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date difference",
    plain_date.until(date_fixture(), date_fixture(), difference_options()),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-GETTEMPORALCALENDARSLOTVALUEWITHISODEFAULT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-gettemporalcalendarslotvaluewithisodefault
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_gettemporalcalendarslotvaluewithisodefault_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date fields",
    plain_date.new(
      year: 1970,
      month: 1,
      day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARDATEFROMFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendardatefromfields
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendardatefromfields_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date fields",
    plain_date.new(
      year: 1970,
      month: 1,
      day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARYEARMONTHFROMFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendaryearmonthfromfields
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendaryearmonthfromfields_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO year-month fields",
    plain_year_month.new(
      year: 1970,
      month: 1,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARMONTHDAYFROMFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarmonthdayfromfields
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendarmonthdayfromfields_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO month-day fields",
    plain_month_day.new(
      month: 1,
      day: 1,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-FORMATCALENDARANNOTATION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-formatcalendarannotation
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_formatcalendarannotation_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar identifier",
    calendar.to_string(calendar.Iso8601),
    "iso8601",
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-ISODAYSINMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-isodaysinmonth
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_isodaysinmonth_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO days in month",
    plain_date.days_in_month(date_fixture()),
    31,
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-ISOWEEKOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-isoweekofyear
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_isoweekofyear_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO week of year",
    plain_date.week_of_year(date_fixture()),
    Some(1),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-ISODAYOFYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-isodayofyear
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_isodayofyear_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO day of year",
    plain_date.day_of_year(date_fixture()),
    1,
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-ISODAYOFWEEK
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-isodayofweek
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_isodayofweek_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO day of week",
    plain_date.day_of_week(date_fixture()),
    4,
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARDATETOISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendardatetoiso
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendardatetoiso_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date fields",
    plain_date.new(
      year: 1970,
      month: 1,
      day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARMONTHDAYTOISOREFERENCEDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarmonthdaytoisoreferencedate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendarmonthdaytoisoreferencedate_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO month-day fields",
    plain_month_day.new(
      month: 1,
      day: 1,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARISOTODATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarisotodate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook-nepali-calendar.md
pub fn temporal_calendarisotodate_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO calendar date fields",
    plain_date.new(
      year: 1970,
      month: 1,
      day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}
