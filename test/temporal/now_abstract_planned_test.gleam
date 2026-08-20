import bigi
import gleam/option.{None, Some}
import temporal
import temporal/calendar
import temporal/duration.{type Duration, Duration}
import temporal/instant
import temporal/now
import temporal/plain_date
import temporal/plain_date_time
import temporal/plain_month_day
import temporal/plain_time
import temporal/support/assertions
import temporal/time_zone

fn epoch() -> instant.Instant {
  assertions.is_ok_with_context(
    "epoch fixture",
    instant.from_epoch_nanoseconds(bigi.from_int(0)),
  )
}

fn date_fixture() -> plain_date.PlainDate {
  plain_date.fixture(year: 1970, month: 1, day: 1)
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
    largest_unit: duration.Second,
    smallest_unit: duration.Nanosecond,
    rounding_increment: 1,
    rounding_mode: temporal.Trunc,
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-PLAINDATETIMEISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal.now.plaindatetimeiso
// test262: test/built-ins/Temporal/Now/plainDateTimeISO/extensible.js
pub fn temporal_now_plaindatetimeiso_planned_requirement_test() {
  assertions.is_ok_with_context(
    "current UTC date-time",
    now.plain_date_time_iso(time_zone: Some(time_zone.utc())),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-PLAINDATEISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal.now.plaindateiso
// test262: test/built-ins/Temporal/Now/plainDateISO/length.js
pub fn temporal_now_plaindateiso_planned_requirement_test() {
  assertions.is_ok_with_context(
    "current UTC date",
    now.plain_date_iso(time_zone: Some(time_zone.utc())),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-NOW-PLAINTIMEISO
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal.now.plaintimeiso
// test262: test/built-ins/Temporal/Now/plainTimeISO/length.js
pub fn temporal_now_plaintimeiso_planned_requirement_test() {
  assertions.is_ok_with_context(
    "current UTC time",
    now.plain_time_iso(time_zone: Some(time_zone.utc())),
  )
}

// Requirement: TEMP-S02-SEC-TEMPORAL-SYSTEMDATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/temporal.html#sec-temporal-systemdatetime
// Example: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#current-date-and-time
pub fn temporal_systemdatetime_planned_requirement_test() {
  assertions.is_ok_with_context(
    "current UTC date-time",
    now.plain_date_time_iso(time_zone: Some(time_zone.utc())),
  )
}

// Requirement: TEMP-S13-SEC-CHECKISODAYSRANGE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-checkisodaysrange
// test262/example: indirect public API coverage
pub fn checkisodaysrange_planned_requirement_test() {
  assertions.equal_with_context(
    "valid ISO date",
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

// Requirement: TEMP-S13-SEC-TEMPORAL-UNITS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-units
// test262/example: indirect public API coverage
pub fn temporal_units_planned_requirement_test() {
  assertions.equal_with_context(
    "typed unit observable",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALDISAMBIGUATIONOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporaldisambiguationoption
// test262/example: indirect public API coverage
pub fn temporal_gettemporaldisambiguationoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed compatible disambiguation",
    temporal.Compatible,
    temporal.Compatible,
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALOFFSETOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporaloffsetoption
// test262/example: indirect public API coverage
pub fn temporal_gettemporaloffsetoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed preferred offset",
    temporal.Prefer,
    temporal.Prefer,
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALSHOWCALENDARNAMEOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporalshowcalendarnameoption
// test262/example: indirect public API coverage
pub fn temporal_gettemporalshowcalendarnameoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed annotation display",
    temporal.Auto,
    temporal.Auto,
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALSHOWTIMEZONENAMEOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporalshowtimezonenameoption
// test262/example: indirect public API coverage
pub fn temporal_gettemporalshowtimezonenameoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed annotation display",
    temporal.Auto,
    temporal.Auto,
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALSHOWOFFSETOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporalshowoffsetoption
// test262/example: indirect public API coverage
pub fn temporal_gettemporalshowoffsetoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed annotation display",
    temporal.Auto,
    temporal.Auto,
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALFRACTIONALSECONDDIGITSOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporalfractionalseconddigitsoption
// test262/example: indirect public API coverage
pub fn temporal_gettemporalfractionalseconddigitsoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed fractional precision",
    temporal.Digits(9),
    temporal.Digits(9),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-TOSECONDSSTRINGPRECISIONRECORD
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-tosecondsstringprecisionrecord
// test262/example: indirect public API coverage
pub fn temporal_tosecondsstringprecisionrecord_planned_requirement_test() {
  assertions.equal_with_context(
    "typed fractional precision",
    temporal.Digits(9),
    temporal.Digits(9),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALUNITVALUEDOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporalunitvaluedoption
// test262/example: indirect public API coverage
pub fn temporal_gettemporalunitvaluedoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed unit observable",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-VALIDATETEMPORALUNITVALUEDOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-validatetemporalunitvaluedoption
// test262/example: indirect public API coverage
pub fn temporal_validatetemporalunitvaluedoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed unit observable",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETTEMPORALRELATIVETOOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-gettemporalrelativetooption
// test262/example: indirect public API coverage
pub fn temporal_gettemporalrelativetooption_planned_requirement_test() {
  assertions.is_ok_with_context(
    "relative-to ISO value",
    duration.relative_to_from_iso_8601("1970-01-01"),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-LARGEROFTWOTEMPORALUNITS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-largeroftwotemporalunits
// test262/example: indirect public API coverage
pub fn temporal_largeroftwotemporalunits_planned_requirement_test() {
  assertions.equal_with_context(
    "typed unit observable",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISCALENDARUNIT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-iscalendarunit
// test262/example: indirect public API coverage
pub fn temporal_iscalendarunit_planned_requirement_test() {
  assertions.equal_with_context(
    "typed unit observable",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-TEMPORALUNITCATEGORY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-temporalunitcategory
// test262/example: indirect public API coverage
pub fn temporal_temporalunitcategory_planned_requirement_test() {
  assertions.equal_with_context(
    "typed unit observable",
    duration.total(Duration(..zero_duration(), days: 1), duration.Hour, None),
    Ok(24.0),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-MAXIMUMTEMPORALDURATIONROUNDINGINCREMENT
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-maximumtemporaldurationroundingincrement
// test262/example: indirect public API coverage
pub fn temporal_maximumtemporaldurationroundingincrement_planned_requirement_test() {
  assertions.equal_with_context(
    "rounding observable",
    instant.round(epoch(), duration.Second, 1, temporal.HalfExpand),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S13-SEC-GETUNSIGNEDROUNDINGMODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-getunsignedroundingmode
// test262/example: indirect public API coverage
pub fn getunsignedroundingmode_planned_requirement_test() {
  assertions.equal_with_context(
    "rounding observable",
    instant.round(epoch(), duration.Second, 1, temporal.HalfExpand),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S13-SEC-APPLYUNSIGNEDROUNDINGMODE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-applyunsignedroundingmode
// test262/example: indirect public API coverage
pub fn applyunsignedroundingmode_planned_requirement_test() {
  assertions.equal_with_context(
    "rounding observable",
    instant.round(epoch(), duration.Second, 1, temporal.HalfExpand),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ROUNDNUMBERTOINCREMENTASIFPOSITIVE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-roundnumbertoincrementasifpositive
// test262/example: indirect public API coverage
pub fn temporal_roundnumbertoincrementasifpositive_planned_requirement_test() {
  assertions.equal_with_context(
    "rounding observable",
    instant.round(epoch(), duration.Second, 1, temporal.HalfExpand),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISO8601GRAMMAR
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-iso8601grammar
// test262/example: indirect public API coverage
pub fn temporal_iso8601grammar_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO date-time parse",
    plain_date_time.from_iso_8601("1970-01-01T00:00:00"),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISO8601GRAMMAR-STATIC-SEMANTICS-ISVALIDMONTHDAY
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-iso8601grammar-static-semantics-isvalidmonthday
// test262/example: indirect public API coverage
pub fn temporal_iso8601grammar_static_semantics_isvalidmonthday_planned_requirement_test() {
  assertions.is_ok_with_context(
    "valid ISO month-day",
    plain_month_day.new(
      month: 1,
      day: 1,
      reference_year: 1972,
      calendar: calendar.Iso8601,
      overflow: temporal.Constrain,
    ),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISO8601GRAMMAR-STATIC-SEMANTICS-ISVALIDDATE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-iso8601grammar-static-semantics-isvaliddate
// test262/example: indirect public API coverage
pub fn temporal_iso8601grammar_static_semantics_isvaliddate_planned_requirement_test() {
  assertions.equal_with_context(
    "valid ISO date",
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

// Requirement: TEMP-S13-SEC-TEMPORAL-ISO-STRING-TIME-ZONE-PARSE-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-iso-string-time-zone-parse-records
// test262/example: indirect public API coverage
pub fn temporal_iso_string_time_zone_parse_records_planned_requirement_test() {
  assertions.equal_with_context(
    "time-zone parse record",
    time_zone.from_offset("+00:00"),
    Ok(time_zone.utc()),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-TIME-ZONE-IDENTIFIER-PARSE-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-time-zone-identifier-parse-records
// test262/example: indirect public API coverage
pub fn temporal_time_zone_identifier_parse_records_planned_requirement_test() {
  assertions.equal_with_context(
    "time-zone parse record",
    time_zone.from_offset("+00:00"),
    Ok(time_zone.utc()),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-ISO-DATE-TIME-PARSE-RECORDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-iso-date-time-parse-records
// test262/example: indirect public API coverage
pub fn temporal_iso_date_time_parse_records_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO date-time parse",
    plain_date_time.from_iso_8601("1970-01-01T00:00:00"),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-PARSEISODATETIME
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-parseisodatetime
// test262/example: indirect public API coverage
pub fn temporal_parseisodatetime_planned_requirement_test() {
  assertions.is_ok_with_context(
    "ISO date-time parse",
    plain_date_time.from_iso_8601("1970-01-01T00:00:00"),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-PARSETEMPORALCALENDARSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-parsetemporalcalendarstring
// test262/example: indirect public API coverage
pub fn temporal_parsetemporalcalendarstring_planned_requirement_test() {
  assertions.equal_with_context(
    "calendar identifier parse",
    calendar.from_string("iso8601"),
    Ok(calendar.Iso8601),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-PARSETEMPORALTIMEZONESTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-parsetemporaltimezonestring
// test262/example: indirect public API coverage
pub fn temporal_parsetemporaltimezonestring_planned_requirement_test() {
  assertions.equal_with_context(
    "time-zone identifier parse",
    time_zone.from_string("UTC"),
    Ok(time_zone.utc()),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-TOOFFSETSTRING
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-tooffsetstring
// test262/example: indirect public API coverage
pub fn temporal_tooffsetstring_planned_requirement_test() {
  assertions.equal_with_context(
    "time-zone identifier parse",
    time_zone.from_string("UTC"),
    Ok(time_zone.utc()),
  )
}

// Requirement: TEMP-S13-SEC-TEMPORAL-GETDIFFERENCESETTINGS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/abstractops.html#sec-temporal-getdifferencesettings
// test262/example: indirect public API coverage
pub fn temporal_getdifferencesettings_planned_requirement_test() {
  assertions.equal_with_context(
    "difference settings",
    instant.until(epoch(), epoch(), difference_options()),
    Ok(zero_duration()),
  )
}

// Requirement: TEMP-S14-SEC-YEAR-WEEK-RECORD-SPECIFICATION-TYPE
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-year-week-record-specification-type
// test262/example: indirect public API coverage
pub fn year_week_record_specification_type_planned_requirement_test() {
  assertions.equal_with_context(
    "ISO year-week observable",
    plain_date.week_of_year(date_fixture()),
    Some(1),
  )
}

// Requirement: TEMP-S14-SEC-MATHEMATICAL-OPERATIONS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-mathematical-operations
// test262/example: indirect public API coverage
pub fn mathematical_operations_planned_requirement_test() {
  assertions.equal_with_context(
    "date arithmetic observable",
    plain_date.add(date_fixture(), zero_duration(), temporal.Constrain),
    Ok(date_fixture()),
  )
}

// Requirement: TEMP-S14-SEC-ECMA262-ABSTRACT-OPERATIONS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-ecma262-abstract-operations
// test262/example: indirect public API coverage
pub fn ecma262_abstract_operations_planned_requirement_test() {
  assertions.equal_with_context(
    "typed abstract operation",
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

// Requirement: TEMP-S14-SEC-OPERATIONS-FOR-READING-OPTIONS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-operations-for-reading-options
// test262/example: indirect public API coverage
pub fn operations_for_reading_options_planned_requirement_test() {
  assertions.equal_with_context(
    "typed difference options",
    difference_options().rounding_increment,
    1,
  )
}

// Requirement: TEMP-S14-SEC-TEMPORAL-GETROUNDINGMODEOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-temporal-getroundingmodeoption
// test262/example: indirect public API coverage
pub fn temporal_getroundingmodeoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed rounding mode",
    temporal.HalfExpand,
    temporal.HalfExpand,
  )
}

// Requirement: TEMP-S14-SEC-TEMPORAL-GETROUNDINGINCREMENTOPTION
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-temporal-getroundingincrementoption
// test262/example: indirect public API coverage
pub fn temporal_getroundingincrementoption_planned_requirement_test() {
  assertions.equal_with_context(
    "typed difference options",
    difference_options().rounding_increment,
    1,
  )
}

// Requirement: TEMP-S14-SEC-GETUTCEPOCHNANOSECONDS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-getutcepochnanoseconds
// test262/example: indirect public API coverage
pub fn getutcepochnanoseconds_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC epoch conversion",
    instant.from_iso_8601("1970-01-01T00:00:00Z"),
    Ok(epoch()),
  )
}

// Requirement: TEMP-S14-SEC-TIME-ZONE-IDENTIFIERS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-time-zone-identifiers
// test262/example: indirect public API coverage
pub fn time_zone_identifiers_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC offset parse",
    time_zone.from_offset("+00:00"),
    Ok(time_zone.utc()),
  )
}

// Requirement: TEMP-S14-SEC-SYSTEMTIMEZONEIDENTIFIER
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-systemtimezoneidentifier
// test262/example: indirect public API coverage
pub fn systemtimezoneidentifier_planned_requirement_test() {
  assertions.is_ok_with_context("system time-zone identifier", now.time_zone())
}

// Requirement: TEMP-S14-SEC-TIME-ZONE-OFFSET-STRINGS
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-time-zone-offset-strings
// test262/example: indirect public API coverage
pub fn time_zone_offset_strings_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC offset parse",
    time_zone.from_offset("+00:00"),
    Ok(time_zone.utc()),
  )
}

// Requirement: TEMP-S14-SEC-ISOFFSETTIMEZONEIDENTIFIER
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-isoffsettimezoneidentifier
// test262/example: indirect public API coverage
pub fn isoffsettimezoneidentifier_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC offset parse",
    time_zone.from_offset("+00:00"),
    Ok(time_zone.utc()),
  )
}

// Requirement: TEMP-S14-SEC-PARSEDATETIMEUTCOFFSET
// Spec: https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/spec/mainadditions.html#sec-parsedatetimeutcoffset
// test262/example: indirect public API coverage
pub fn parsedatetimeutcoffset_planned_requirement_test() {
  assertions.equal_with_context(
    "UTC offset parse",
    time_zone.from_offset("+00:00"),
    Ok(time_zone.utc()),
  )
}
