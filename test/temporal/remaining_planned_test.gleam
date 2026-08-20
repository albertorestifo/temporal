import bigi
import gleam/option.{None, Some}
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

fn date() -> plain_date.PlainDate {
  plain_date.fixture(year: 2026, month: 8, day: 20)
}

fn time() -> plain_time.PlainTime {
  plain_time.fixture(
    hour: 12,
    minute: 34,
    second: 56,
    millisecond: 123,
    microsecond: 456,
    nanosecond: 789,
  )
}

fn date_time() -> plain_date_time.PlainDateTime {
  plain_date_time.fixture(date: date(), time: time())
}

fn year_month() -> plain_year_month.PlainYearMonth {
  plain_year_month.fixture(year: 2026, month: 8, reference_day: 1)
}

fn month_day() -> plain_month_day.PlainMonthDay {
  plain_month_day.fixture(month: 8, day: 20, reference_year: 1972)
}

fn epoch() -> instant.Instant {
  assertions.is_ok_with_context(
    "epoch fixture",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
  )
}

fn zoned() -> zoned_date_time.ZonedDateTime {
  assertions.is_ok_with_context(
    "zoned fixture",
    zoned_date_time.from_instant(epoch(), time_zone.utc(), calendar.Iso8601),
  )
}

fn named_zone() -> time_zone.TimeZone {
  time_zone.named_fixture("Europe/Madrid")
}

fn partial_date() -> plain_date.PartialDate {
  plain_date.PartialDate(
    year: Some(2027),
    month: None,
    month_code: None,
    day: None,
  )
}

fn partial_time() -> plain_time.PartialTime {
  plain_time.PartialTime(
    hour: Some(13),
    minute: None,
    second: None,
    millisecond: None,
    microsecond: None,
    nanosecond: None,
  )
}

fn partial_date_time() -> plain_date_time.PartialDateTime {
  plain_date_time.PartialDateTime(
    year: Some(2027),
    month: None,
    month_code: None,
    day: None,
    hour: None,
    minute: None,
    second: None,
    millisecond: None,
    microsecond: None,
    nanosecond: None,
  )
}

fn partial_year_month() -> plain_year_month.PartialYearMonth {
  plain_year_month.PartialYearMonth(
    year: Some(2027),
    month: None,
    month_code: None,
  )
}

fn partial_month_day() -> plain_month_day.PartialMonthDay {
  plain_month_day.PartialMonthDay(month: None, month_code: None, day: Some(21))
}

fn partial_zoned() -> zoned_date_time.PartialZonedDateTime {
  zoned_date_time.PartialZonedDateTime(
    year: Some(2027),
    month: None,
    month_code: None,
    day: None,
    hour: None,
    minute: None,
    second: None,
    millisecond: None,
    microsecond: None,
    nanosecond: None,
    offset: None,
  )
}

fn calendar_fields() -> calendar.CalendarFields {
  calendar.CalendarFields(
    era: None,
    era_year: None,
    year: Some(2026),
    month: Some(8),
    month_code: Some("M08"),
    day: Some(20),
  )
}

fn iso_date() -> calendar.IsoDateFields {
  calendar.IsoDateFields(year: 2026, month: 8, day: 20)
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

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-ERA
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.era
// test262: test/built-ins/Temporal/PlainDate/prototype/era/basic.js
pub fn plain_date_iso_era_is_absent_test() {
  assertions.equal_with_context("ISO era", plain_date.era(date()), None)
}

// Requirement: TEMP-S03-SEC-GET-TEMPORAL-PLAINDATE-PROTOTYPE-ERAYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-get-temporal.plaindate.prototype.erayear
// test262: test/built-ins/Temporal/PlainDate/prototype/eraYear/basic.js
pub fn plain_date_iso_era_year_is_absent_test() {
  assertions.equal_with_context(
    "ISO era year",
    plain_date.era_year(date()),
    None,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-ERA
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.era
// test262: test/built-ins/Temporal/PlainDateTime/prototype/era/basic.js
pub fn plain_date_time_iso_era_is_absent_test() {
  assertions.equal_with_context(
    "ISO date-time era",
    plain_date_time.era(date_time()),
    None,
  )
}

// Requirement: TEMP-S05-SEC-GET-TEMPORAL-PLAINDATETIME-PROTOTYPE-ERAYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-get-temporal.plaindatetime.prototype.erayear
// test262: test/built-ins/Temporal/PlainDateTime/prototype/eraYear/basic.js
pub fn plain_date_time_iso_era_year_is_absent_test() {
  assertions.equal_with_context(
    "ISO date-time era year",
    plain_date_time.era_year(date_time()),
    None,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-ERA
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.era
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/era/basic.js
pub fn plain_year_month_iso_era_is_absent_test() {
  assertions.equal_with_context(
    "ISO year-month era",
    plain_year_month.era(year_month()),
    None,
  )
}

// Requirement: TEMP-S09-SEC-GET-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-ERAYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-get-temporal.plainyearmonth.prototype.erayear
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/eraYear/basic.js
pub fn plain_year_month_iso_era_year_is_absent_test() {
  assertions.equal_with_context(
    "ISO year-month era year",
    plain_year_month.era_year(year_month()),
    None,
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-ERA
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.era
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/era/basic.js
pub fn zoned_date_time_iso_era_is_absent_test() {
  assertions.equal_with_context(
    "ISO zoned era",
    zoned_date_time.era(zoned()),
    Ok(None),
  )
}

// Requirement: TEMP-S06-SEC-GET-TEMPORAL-ZONEDDATETIME-PROTOTYPE-ERAYEAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-get-temporal.zoneddatetime.prototype.erayear
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/eraYear/basic.js
pub fn zoned_date_time_iso_era_year_is_absent_test() {
  assertions.equal_with_context(
    "ISO zoned era year",
    zoned_date_time.era_year(zoned()),
    Ok(None),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-WITH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.with
// test262: test/built-ins/Temporal/PlainDate/prototype/with/basic-year-month-day.js
pub fn plain_date_with_fields_replaces_typed_year_test() {
  assertions.is_ok_with_context(
    "typed date replacement",
    plain_date.with_fields(date(), partial_date(), temporal.Constrain),
  )
}

// Requirement: TEMP-S03-SEC-TEMPORAL-PLAINDATE-PROTOTYPE-WITHCALENDAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindate.html#sec-temporal.plaindate.prototype.withcalendar
// test262: test/built-ins/Temporal/PlainDate/prototype/withCalendar/basic.js
pub fn plain_date_with_calendar_accepts_variant_test() {
  assertions.is_ok_with_context(
    "typed date calendar replacement",
    plain_date.with_calendar(date(), calendar.Gregory),
  )
}

// Requirement: TEMP-S04-SEC-TEMPORAL-PLAINTIME-PROTOTYPE-WITH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaintime.html#sec-temporal.plaintime.prototype.with
// test262: test/built-ins/Temporal/PlainTime/prototype/with/basic.js
pub fn plain_time_with_fields_replaces_typed_hour_test() {
  assertions.is_ok_with_context(
    "typed time replacement",
    plain_time.with_fields(time(), partial_time(), temporal.Constrain),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-WITH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.with
// test262: test/built-ins/Temporal/PlainDateTime/prototype/with/basic.js
pub fn plain_date_time_with_fields_replaces_typed_year_test() {
  assertions.is_ok_with_context(
    "typed date-time replacement",
    plain_date_time.with_fields(
      date_time(),
      partial_date_time(),
      temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-WITHPLAINTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.withplaintime
// test262: test/built-ins/Temporal/PlainDateTime/prototype/withPlainTime/basic.js
pub fn plain_date_time_with_plain_time_accepts_typed_time_test() {
  assertions.is_ok_with_context(
    "typed date-time time replacement",
    plain_date_time.with_plain_time(date_time(), Some(time())),
  )
}

// Requirement: TEMP-S05-SEC-TEMPORAL-PLAINDATETIME-PROTOTYPE-WITHCALENDAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plaindatetime.html#sec-temporal.plaindatetime.prototype.withcalendar
// test262: test/built-ins/Temporal/PlainDateTime/prototype/withCalendar/basic.js
pub fn plain_date_time_with_calendar_accepts_variant_test() {
  assertions.is_ok_with_context(
    "typed date-time calendar replacement",
    plain_date_time.with_calendar(date_time(), calendar.Gregory),
  )
}

// Requirement: TEMP-S09-SEC-TEMPORAL-PLAINYEARMONTH-PROTOTYPE-WITH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainyearmonth.html#sec-temporal.plainyearmonth.prototype.with
// test262: test/built-ins/Temporal/PlainYearMonth/prototype/with/basic.js
pub fn plain_year_month_with_fields_replaces_typed_year_test() {
  assertions.is_ok_with_context(
    "typed year-month replacement",
    plain_year_month.with_fields(
      year_month(),
      partial_year_month(),
      temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S10-SEC-TEMPORAL-PLAINMONTHDAY-PROTOTYPE-WITH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/plainmonthday.html#sec-temporal.plainmonthday.prototype.with
// test262: test/built-ins/Temporal/PlainMonthDay/prototype/with/basic.js
pub fn plain_month_day_with_fields_replaces_typed_day_test() {
  assertions.is_ok_with_context(
    "typed month-day replacement",
    plain_month_day.with_fields(
      month_day(),
      partial_month_day(),
      temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-WITH
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.with
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/with/basic.js
pub fn zoned_date_time_with_fields_accepts_typed_partial_test() {
  assertions.is_ok_with_context(
    "typed zoned replacement",
    zoned_date_time.with_fields(
      zoned(),
      partial_zoned(),
      temporal.Constrain,
      temporal.Compatible,
      temporal.Prefer,
    ),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-WITHPLAINTIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.withplaintime
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/withPlainTime/basic.js
pub fn zoned_date_time_with_plain_time_accepts_typed_time_test() {
  assertions.is_ok_with_context(
    "typed zoned time replacement",
    zoned_date_time.with_plain_time(zoned(), Some(time())),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-WITHTIMEZONE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.withtimezone
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/withTimeZone/builtin.js
pub fn zoned_date_time_with_time_zone_accepts_validated_zone_test() {
  assertions.is_ok_with_context(
    "typed zoned time-zone replacement",
    zoned_date_time.with_time_zone(zoned(), named_zone()),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-WITHCALENDAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.withcalendar
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/withCalendar/builtin.js
pub fn zoned_date_time_with_calendar_accepts_variant_test() {
  assertions.is_ok_with_context(
    "typed zoned calendar replacement",
    zoned_date_time.with_calendar(zoned(), calendar.Gregory),
  )
}

// Requirement: TEMP-S06-SEC-TEMPORAL-ZONEDDATETIME-PROTOTYPE-GETTIMEZONETRANSITION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/zoneddatetime.html#sec-temporal.zoneddatetime.prototype.gettimezonetransition
// test262: test/built-ins/Temporal/ZonedDateTime/prototype/getTimeZoneTransition/builtin.js
pub fn zoned_date_time_get_transition_uses_typed_direction_test() {
  assertions.is_ok_with_context(
    "next zoned transition",
    zoned_date_time.get_time_zone_transition(zoned(), temporal.Next),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETNAMEDTIMEZONENEXTTRANSITION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getnamedtimezonenexttransition
// test262/example: named-zone provider boundary
pub fn named_time_zone_next_transition_requires_provider_test() {
  assertions.is_ok_with_context(
    "next named-zone transition",
    time_zone.next_transition(named_zone(), epoch()),
  )
}

// Requirement: TEMP-S11-SEC-TEMPORAL-GETNAMEDTIMEZONEPREVIOUSTRANSITION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/timezone.html#sec-temporal-getnamedtimezoneprevioustransition
// test262/example: named-zone provider boundary
pub fn named_time_zone_previous_transition_requires_provider_test() {
  assertions.is_ok_with_context(
    "previous named-zone transition",
    time_zone.previous_transition(named_zone(), epoch()),
  )
}

// Requirement: TEMP-S14-SEC-GETNAMEDTIMEZONEEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-getnamedtimezoneepochnanoseconds
// test262/example: named-zone provider boundary
pub fn named_time_zone_possible_instants_require_provider_test() {
  assertions.is_ok_with_context(
    "named-zone possible instants",
    time_zone.possible_instants_for(named_zone(), date_time()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-PREPARECALENDARFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-preparecalendarfields
// test262/example: typed calendar field preparation
pub fn prepare_calendar_fields_accepts_typed_record_test() {
  assertions.is_ok_with_context(
    "calendar field preparation",
    calendar.prepare_fields(calendar.Hebrew, calendar_fields()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARFIELDKEYSPRESENT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarfieldkeyspresent
// test262/example: typed calendar field enumeration
pub fn calendar_field_keys_present_returns_typed_keys_test() {
  assertions.equal_with_context(
    "calendar field keys",
    calendar.field_keys_present(calendar_fields()),
    [
      calendar.YearField,
      calendar.MonthField,
      calendar.MonthCodeField,
      calendar.DayField,
    ],
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARMERGEFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarmergefields
// test262/example: typed calendar field merge
pub fn calendar_merge_fields_accepts_typed_records_test() {
  assertions.is_ok_with_context(
    "calendar field merge",
    calendar.merge_fields(calendar.Hebrew, calendar_fields(), calendar_fields()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-NONISODATEADD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-nonisodateadd
// test262/example: non-ISO calendar provider boundary
pub fn non_iso_date_add_requires_calendar_provider_test() {
  assertions.is_ok_with_context(
    "Hebrew date addition",
    calendar.non_iso_date_add(
      calendar.Hebrew,
      iso_date(),
      zero_duration(),
      temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-NONISODATEUNTIL
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-nonisodateuntil
// test262/example: non-ISO calendar provider boundary
pub fn non_iso_date_until_requires_calendar_provider_test() {
  assertions.is_ok_with_context(
    "Hebrew date difference",
    calendar.non_iso_date_until(
      calendar.Hebrew,
      iso_date(),
      iso_date(),
      duration.Day,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-NONISOCALENDARDATETOISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-nonisocalendardatetoiso
// test262/example: non-ISO calendar provider boundary
pub fn non_iso_calendar_date_to_iso_requires_provider_test() {
  assertions.is_ok_with_context(
    "Hebrew date to ISO",
    calendar.non_iso_date_to_iso(
      calendar.Hebrew,
      calendar_fields(),
      temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-NONISOMONTHDAYTOISOREFERENCEDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-nonisomonthdaytoisoreferencedate
// test262/example: non-ISO calendar provider boundary
pub fn non_iso_month_day_to_iso_reference_date_requires_provider_test() {
  assertions.is_ok_with_context(
    "Hebrew month-day to ISO",
    calendar.non_iso_month_day_to_iso_reference_date(
      calendar.Hebrew,
      calendar_fields(),
      temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-NONISOCALENDARISOTODATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-nonisocalendarisotodate
// test262/example: non-ISO calendar provider boundary
pub fn non_iso_calendar_iso_to_date_requires_provider_test() {
  assertions.is_ok_with_context(
    "ISO to Hebrew date",
    calendar.non_iso_iso_to_date(calendar.Hebrew, iso_date()),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDAREXTRAFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarextrafields
// test262/example: typed calendar field enumeration
pub fn calendar_extra_fields_returns_typed_keys_test() {
  assertions.equal_with_context(
    "Gregorian extra fields",
    calendar.extra_fields(calendar.Gregory, [calendar.YearField]),
    [calendar.EraField, calendar.EraYearField],
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-NONISOFIELDKEYSTOIGNORE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-nonisofieldkeystoignore
// test262/example: typed calendar field enumeration
pub fn non_iso_field_keys_to_ignore_returns_typed_keys_test() {
  assertions.equal_with_context(
    "Gregorian ignored fields",
    calendar.non_iso_field_keys_to_ignore(calendar.Gregory, [calendar.YearField]),
    [calendar.EraYearField],
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARFIELDKEYSTOIGNORE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarfieldkeystoignore
// test262/example: typed calendar field enumeration
pub fn calendar_field_keys_to_ignore_returns_typed_keys_test() {
  assertions.equal_with_context(
    "calendar ignored fields",
    calendar.field_keys_to_ignore(calendar.Gregory, [calendar.YearField]),
    [calendar.EraYearField],
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-NONISORESOLVEFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-nonisoresolvefields
// test262/example: typed calendar field resolution
pub fn non_iso_resolve_fields_requires_calendar_provider_test() {
  assertions.is_ok_with_context(
    "Hebrew field resolution",
    calendar.non_iso_resolve_fields(
      calendar.Hebrew,
      calendar_fields(),
      calendar.DateFields,
    ),
  )
}

// Requirement: TEMP-S12-SEC-TEMPORAL-CALENDARRESOLVEFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/calendar.html#sec-temporal-calendarresolvefields
// test262/example: typed calendar field resolution
pub fn calendar_resolve_fields_requires_calendar_provider_test() {
  assertions.is_ok_with_context(
    "calendar field resolution",
    calendar.resolve_fields(
      calendar.Hebrew,
      calendar_fields(),
      calendar.DateFields,
    ),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETDIRECTIONOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-getdirectionoption
// test262/example: typed direction option
pub fn direction_option_is_a_closed_variant_test() {
  assertions.is_ok_with_context(
    "previous named-zone transition",
    time_zone.previous_transition(named_zone(), epoch()),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISPARTIALTEMPORALOBJECT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-ispartialtemporalobject
// test262/example: labeled optional Temporal fields
pub fn partial_temporal_object_uses_labeled_options_test() {
  assertions.is_ok_with_context(
    "partial Temporal date",
    plain_date.with_fields(date(), partial_date(), temporal.Constrain),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISODATETOFIELDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-isodatetofields
// test262/example: typed ISO and calendar field records
pub fn iso_date_to_fields_uses_typed_records_test() {
  assertions.is_ok_with_context(
    "typed ISO date conversion",
    calendar.iso_date_to_fields(
      calendar.Gregory,
      iso_date(),
      calendar.DateFields,
    ),
  )
}
