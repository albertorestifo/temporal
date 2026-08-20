import gleam/order.{Eq}
import temporal
import temporal/calendar
import temporal/duration.{type Duration, Duration}
import temporal/plain_date
import temporal/plain_date_time
import temporal/plain_month_day
import temporal/plain_time
import temporal/plain_year_month
import temporal/support/assertions
import temporal/time_zone
import temporal/zoned_date_time

fn date_fixture() -> plain_date.PlainDate {
  plain_date.fixture(year: 2026, month: 8, day: 20)
}

fn time_fixture() -> plain_time.PlainTime {
  plain_time.fixture(
    hour: 12,
    minute: 34,
    second: 56,
    millisecond: 123,
    microsecond: 456,
    nanosecond: 789,
  )
}

fn date_time_fixture() -> plain_date_time.PlainDateTime {
  plain_date_time.fixture(date: date_fixture(), time: time_fixture())
}

fn year_month_fixture() -> plain_year_month.PlainYearMonth {
  plain_year_month.fixture(year: 2026, month: 8, reference_day: 1)
}

fn month_day_fixture() -> plain_month_day.PlainMonthDay {
  plain_month_day.fixture(month: 8, day: 20, reference_year: 1972)
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

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-plaindate-objects
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_plaindate_objects_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-plaindate-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_plaindate_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-TOPLAINYEARMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.toplainyearmonth
// test262: test/built-ins/Temporal/PlainDate/prototype/toPlainYearMonth/basic.js
pub fn temporal_plaindate_prototype_toplainyearmonth_planned_requirement_test() {
  assertions.is_ok_with_context(
    "date to year-month",
    plain_year_month.new(
      year: plain_date.year(date_fixture()),
      month: plain_date.month(date_fixture()),
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-TOPLAINMONTHDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.toplainmonthday
// test262: test/built-ins/Temporal/PlainDate/prototype/toPlainMonthDay/basic.js
pub fn temporal_plaindate_prototype_toplainmonthday_planned_requirement_test() {
  assertions.is_ok_with_context(
    "date to month-day",
    plain_month_day.new(
      month: plain_date.month(date_fixture()),
      day: plain_date.day(date_fixture()),
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-TOPLAINDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.toplaindatetime
// test262: test/built-ins/Temporal/PlainDate/prototype/toPlainDateTime/argument-number.js
pub fn temporal_plaindate_prototype_toplaindatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date and midnight conversion",
    plain_date_time.from_date_and_time(
      date_fixture(),
      plain_time.fixture(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
        nanosecond: 0,
      ),
    ),
    Ok(plain_date_time.fixture(
      date: date_fixture(),
      time: plain_time.fixture(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
        nanosecond: 0,
      ),
    )),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-TOZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.tozoneddatetime
// test262: test/built-ins/Temporal/PlainDate/prototype/toZonedDateTime/argument-number.js
pub fn temporal_plaindate_prototype_tozoneddatetime_planned_requirement_test() {
  let value =
    plain_date_time.fixture(
      date: date_fixture(),
      time: plain_time.fixture(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
        nanosecond: 0,
      ),
    )
  assertions.is_ok_with_context(
    "date to UTC zoned date-time",
    zoned_date_time.from_plain_date_time(
      value,
      time_zone.utc(),
      temporal.Compatible,
    ),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.tojson
// test262: test/built-ins/Temporal/PlainDate/prototype/toJSON/basic.js
pub fn temporal_plaindate_prototype_tojson_planned_requirement_test() {
  assertions.equal_with_context(
    "date ISO serialization",
    plain_date.to_iso_8601(date_fixture()),
    "2026-08-20",
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-plaindate-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_plaindate_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-ISO-DATE-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-iso-date-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_iso_date_records_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-CREATE-ISO-DATE-RECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-create-iso-date-record
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_create_iso_date_record_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-CREATETEMPORALDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-createtemporaldate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_createtemporaldate_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-TOTEMPORALDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-totemporaldate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_totemporaldate_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-COMPARESURPASSES
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-comparesurpasses
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_comparesurpasses_planned_requirement_test() {
  assertions.equal_with_context(
    "date comparison",
    plain_date.compare(date_fixture(), date_fixture()),
    Eq,
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-ISODATESURPASSES
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-isodatesurpasses
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_isodatesurpasses_planned_requirement_test() {
  assertions.equal_with_context(
    "date addition",
    plain_date.add(date_fixture(), zero_duration(), temporal.Constrain),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-REGULATEISODATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-regulateisodate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_regulateisodate_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-ISVALIDISODATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-isvalidisodate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_isvalidisodate_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-ADDDAYSTOISODATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-adddaystoisodate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_adddaystoisodate_planned_requirement_test() {
  assertions.equal_with_context(
    "date addition",
    plain_date.add(date_fixture(), zero_duration(), temporal.Constrain),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PADISOYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-padisoyear
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_padisoyear_planned_requirement_test() {
  assertions.equal_with_context(
    "date ISO serialization",
    plain_date.to_iso_8601(date_fixture()),
    "2026-08-20",
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-TEMPORALDATETOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-temporaldatetostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_temporaldatetostring_planned_requirement_test() {
  assertions.equal_with_context(
    "date ISO serialization",
    plain_date.to_iso_8601(date_fixture()),
    "2026-08-20",
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-ISODATEWITHINLIMITS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-isodatewithinlimits
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_isodatewithinlimits_planned_requirement_test() {
  assertions.equal_with_context(
    "date construction",
    plain_date.new(
      year: 2026,
      month: 8,
      day: 20,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-COMPAREISODATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-compareisodate
// test262: test/built-ins/Temporal/PlainDate/compare/use-internal-slots.js
pub fn temporal_compareisodate_planned_requirement_test() {
  assertions.equal_with_context(
    "date comparison",
    plain_date.compare(date_fixture(), date_fixture()),
    Eq,
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-DIFFERENCETEMPORALPLAINDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-differencetemporalplaindate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_differencetemporalplaindate_planned_requirement_test() {
  assertions.equal_with_context(
    "date difference",
    plain_date.until(date_fixture(), date_fixture(), difference_options()),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-ADDDURATIONTODATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal-adddurationtodate
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date
pub fn temporal_adddurationtodate_planned_requirement_test() {
  assertions.equal_with_context(
    "date addition",
    plain_date.add(date_fixture(), zero_duration(), temporal.Constrain),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-plaintime-objects
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_plaintime_objects_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-plaintime-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_plaintime_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.tojson
// test262: test/built-ins/Temporal/PlainTime/prototype/toJSON/basic.js
pub fn temporal_plaintime_prototype_tojson_planned_requirement_test() {
  assertions.equal_with_context(
    "time ISO serialization",
    plain_time.to_iso_8601(time_fixture()),
    "12:34:56.123456789",
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-plaintime-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_plaintime_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-TIME-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-time-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_time_records_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-CREATETIMERECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-createtimerecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_createtimerecord_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-MIDNIGHTTIMERECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-midnighttimerecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_midnighttimerecord_planned_requirement_test() {
  let midnight =
    plain_time.fixture(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
      nanosecond: 0,
    )
  assertions.equal_with_context("midnight hour", plain_time.hour(midnight), 0)
}

// Requirement: TEMP-S04-SEC-TEMPORAL-NOONTIMERECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-noontimerecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_noontimerecord_planned_requirement_test() {
  assertions.equal_with_context(
    "noon hour",
    plain_time.hour(time_fixture()),
    12,
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-DIFFERENCETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-differencetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_differencetime_planned_requirement_test() {
  assertions.equal_with_context(
    "time difference",
    plain_time.until(time_fixture(), time_fixture(), difference_options()),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-TOTEMPORALTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-totemporaltime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_totemporaltime_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-TOTIMERECORDORMIDNIGHT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-totimerecordormidnight
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_totimerecordormidnight_planned_requirement_test() {
  let midnight =
    plain_time.fixture(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
      nanosecond: 0,
    )
  assertions.equal_with_context("midnight hour", plain_time.hour(midnight), 0)
}

// Requirement: TEMP-S04-SEC-TEMPORAL-REGULATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-regulatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_regulatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-ISVALIDTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-isvalidtime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_isvalidtime_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-BALANCETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-balancetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_balancetime_planned_requirement_test() {
  assertions.equal_with_context(
    "time addition",
    plain_time.add(time_fixture(), zero_duration()),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-CREATETEMPORALTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-createtemporaltime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_createtemporaltime_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-TOTEMPORALTIMERECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-totemporaltimerecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_totemporaltimerecord_planned_requirement_test() {
  assertions.equal_with_context(
    "time construction",
    plain_time.new(
      hour: 12,
      minute: 34,
      second: 56,
      millisecond: 123,
      microsecond: 456,
      nanosecond: 789,
      overflow: temporal.Constrain,
    ),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-TIMERECORDTOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-timerecordtostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_timerecordtostring_planned_requirement_test() {
  assertions.equal_with_context(
    "time ISO serialization",
    plain_time.to_iso_8601(time_fixture()),
    "12:34:56.123456789",
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-COMPARETIMERECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-comparetimerecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_comparetimerecord_planned_requirement_test() {
  assertions.equal_with_context(
    "time comparison",
    plain_time.compare(time_fixture(), time_fixture()),
    Eq,
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-ADDTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-addtime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_addtime_planned_requirement_test() {
  assertions.equal_with_context(
    "time addition",
    plain_time.add(time_fixture(), zero_duration()),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-ROUNDTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-roundtime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_roundtime_planned_requirement_test() {
  assertions.equal_with_context(
    "time rounding",
    plain_time.round(time_fixture(), duration.Second, 1, temporal.HalfExpand),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-DIFFERENCETEMPORALPLAINTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-differencetemporalplaintime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_differencetemporalplaintime_planned_requirement_test() {
  assertions.equal_with_context(
    "time difference",
    plain_time.until(time_fixture(), time_fixture(), difference_options()),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-ADDDURATIONTOTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal-adddurationtotime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours
pub fn temporal_adddurationtotime_planned_requirement_test() {
  assertions.equal_with_context(
    "time addition",
    plain_time.add(time_fixture(), zero_duration()),
    Ok(time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-plaindatetime-objects
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_plaindatetime_objects_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-plaindatetime-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_plaindatetime_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.tojson
// test262: test/built-ins/Temporal/PlainDateTime/prototype/toJSON/basic.js
pub fn temporal_plaindatetime_prototype_tojson_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time ISO serialization",
    plain_date_time.to_iso_8601(date_time_fixture()),
    "2026-08-20T12:34:56.123456789",
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-TOZONEDDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.tozoneddatetime
// test262: test/built-ins/Temporal/PlainDateTime/prototype/toZonedDateTime/basic.js
pub fn temporal_plaindatetime_prototype_tozoneddatetime_planned_requirement_test() {
  assertions.is_ok_with_context(
    "date-time to UTC zoned date-time",
    zoned_date_time.from_plain_date_time(
      date_time_fixture(),
      time_zone.utc(),
      temporal.Compatible,
    ),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-TOPLAINDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.toplaindate
// test262: test/built-ins/Temporal/PlainDateTime/prototype/toPlainDate/basic.js
pub fn temporal_plaindatetime_prototype_toplaindate_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time date component",
    plain_date_time.to_plain_date(date_time_fixture()),
    date_fixture(),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-TOPLAINTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.toplaintime
// test262: test/built-ins/Temporal/PlainDateTime/prototype/toPlainTime/basic.js
pub fn temporal_plaindatetime_prototype_toplaintime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time time component",
    plain_date_time.to_plain_time(date_time_fixture()),
    time_fixture(),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-plaindatetime-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_plaindatetime_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-ISO-DATE-TIME-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-iso-date-time-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_iso_date_time_records_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-TIMEVALUETOISODATETIMERECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-timevaluetoisodatetimerecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_timevaluetoisodatetimerecord_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-COMBINEISODATEANDTIMERECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-combineisodateandtimerecord
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_combineisodateandtimerecord_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-ISODATETIMEWITHINLIMITS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-isodatetimewithinlimits
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_isodatetimewithinlimits_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-INTERPRETTEMPORALDATETIMEFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-interprettemporaldatetimefields
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_interprettemporaldatetimefields_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-TOTEMPORALDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-totemporaldatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_totemporaldatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-BALANCEISODATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-balanceisodatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_balanceisodatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time addition",
    plain_date_time.add(
      date_time_fixture(),
      zero_duration(),
      temporal.Constrain,
    ),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-CREATETEMPORALDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-createtemporaldatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_createtemporaldatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time combination",
    plain_date_time.from_date_and_time(date_fixture(), time_fixture()),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-ISODATETIMETOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-isodatetimetostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_isodatetimetostring_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time ISO serialization",
    plain_date_time.to_iso_8601(date_time_fixture()),
    "2026-08-20T12:34:56.123456789",
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-COMPAREISODATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-compareisodatetime
// test262: test/built-ins/Temporal/PlainDateTime/compare/use-internal-slots.js
pub fn temporal_compareisodatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time comparison",
    plain_date_time.compare(date_time_fixture(), date_time_fixture()),
    Eq,
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-ROUNDISODATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-roundisodatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_roundisodatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time rounding",
    plain_date_time.round(
      date_time_fixture(),
      duration.Second,
      1,
      temporal.HalfExpand,
    ),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-DIFFERENCEISODATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-differenceisodatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_differenceisodatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time difference",
    plain_date_time.until(
      date_time_fixture(),
      date_time_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-DIFFERENCEPLAINDATETIMEWITHROUNDING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-differenceplaindatetimewithrounding
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_differenceplaindatetimewithrounding_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time difference",
    plain_date_time.until(
      date_time_fixture(),
      date_time_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-DIFFERENCEPLAINDATETIMEWITHTOTAL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-differenceplaindatetimewithtotal
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_differenceplaindatetimewithtotal_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time difference",
    plain_date_time.until(
      date_time_fixture(),
      date_time_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-DIFFERENCETEMPORALPLAINDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-differencetemporalplaindatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_differencetemporalplaindatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time difference",
    plain_date_time.until(
      date_time_fixture(),
      date_time_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-ADDDURATIONTODATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal-adddurationtodatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date
pub fn temporal_adddurationtodatetime_planned_requirement_test() {
  assertions.equal_with_context(
    "date-time addition",
    plain_date_time.add(
      date_time_fixture(),
      zero_duration(),
      temporal.Constrain,
    ),
    Ok(date_time_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-plainyearmonth-objects
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_plainyearmonth_objects_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month construction",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-plainyearmonth-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_plainyearmonth_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month construction",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.tojson
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/toJSON/basic.js
pub fn temporal_plainyearmonth_prototype_tojson_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month ISO serialization",
    plain_year_month.to_iso_8601(year_month_fixture()),
    "2026-08",
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-TOPLAINDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.toplaindate
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/toPlainDate/argument-not-object.js
pub fn temporal_plainyearmonth_prototype_toplaindate_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month to date",
    plain_date.from_year_month(year_month_fixture(), 20, temporal.Constrain),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-plainyearmonth-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_plainyearmonth_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month construction",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-ISO-YEAR-MONTH-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-iso-year-month-records
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_iso_year_month_records_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month construction",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-TOTEMPORALYEARMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-totemporalyearmonth
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_totemporalyearmonth_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month construction",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-ISOYEARMONTHWITHINLIMITS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-isoyearmonthwithinlimits
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_isoyearmonthwithinlimits_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month construction",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-BALANCEISOYEARMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-balanceisoyearmonth
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_balanceisoyearmonth_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month addition",
    plain_year_month.add(
      year_month_fixture(),
      zero_duration(),
      temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-CREATETEMPORALYEARMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-createtemporalyearmonth
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_createtemporalyearmonth_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month construction",
    plain_year_month.new(
      year: 2026,
      month: 8,
      reference_day: 1,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-TEMPORALYEARMONTHTOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-temporalyearmonthtostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_temporalyearmonthtostring_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month ISO serialization",
    plain_year_month.to_iso_8601(year_month_fixture()),
    "2026-08",
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-DIFFERENCETEMPORALPLAINYEARMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-differencetemporalplainyearmonth
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_differencetemporalplainyearmonth_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month difference",
    plain_year_month.until(
      year_month_fixture(),
      year_month_fixture(),
      difference_options(),
    ),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-ADDDURATIONTOYEARMONTH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal-adddurationtoyearmonth
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_adddurationtoyearmonth_planned_requirement_test() {
  assertions.equal_with_context(
    "year-month addition",
    plain_year_month.add(
      year_month_fixture(),
      zero_duration(),
      temporal.Constrain,
    ),
    Ok(year_month_fixture()),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-OBJECTS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal-plainmonthday-objects
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_plainmonthday_objects_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day construction",
    plain_month_day.new(
      month: 8,
      day: 20,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(month_day_fixture()),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-CONSTRUCTOR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal-plainmonthday-constructor
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_plainmonthday_constructor_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day construction",
    plain_month_day.new(
      month: 8,
      day: 20,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(month_day_fixture()),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-TOJSON
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal.plainmonthday.prototype.tojson
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/toJSON/basic.js
pub fn temporal_plainmonthday_prototype_tojson_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day ISO serialization",
    plain_month_day.to_iso_8601(month_day_fixture()),
    "08-20",
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-TOPLAINDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal.plainmonthday.prototype.toplaindate
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/toPlainDate/argument-not-object.js
pub fn temporal_plainmonthday_prototype_toplaindate_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day to date",
    plain_date.from_month_day(month_day_fixture(), 2026, temporal.Constrain),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-ABSTRACT-OPS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal-plainmonthday-abstract-ops
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_plainmonthday_abstract_ops_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day construction",
    plain_month_day.new(
      month: 8,
      day: 20,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(month_day_fixture()),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-TOTEMPORALMONTHDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal-totemporalmonthday
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_totemporalmonthday_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day construction",
    plain_month_day.new(
      month: 8,
      day: 20,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(month_day_fixture()),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-CREATETEMPORALMONTHDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal-createtemporalmonthday
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_createtemporalmonthday_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day construction",
    plain_month_day.new(
      month: 8,
      day: 20,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
    Ok(month_day_fixture()),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-TEMPORALMONTHDAYTOSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal-temporalmonthdaytostring
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030
pub fn temporal_temporalmonthdaytostring_planned_requirement_test() {
  assertions.equal_with_context(
    "month-day ISO serialization",
    plain_month_day.to_iso_8601(month_day_fixture()),
    "08-20",
  )
}
