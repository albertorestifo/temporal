//// Calendar identifiers used by Temporal values.
////
//// The core package currently provides the ISO 8601 calendar. Additional
//// calendars require an explicit, versioned provider.

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import temporal
import temporal/duration
import temporal/internal/iso_plain

/// A supported calendar.
///
/// Each built-in calendar is represented by a variant rather than a string.
/// Non-ISO variants require a calendar-data provider for calculations.
pub type Calendar {
  Iso8601
  Buddhist
  Chinese
  Coptic
  Dangi
  Ethioaa
  Ethiopian
  Gregory
  Hebrew
  Indian
  Islamic
  IslamicCivil
  IslamicRgsa
  IslamicTabular
  IslamicUmalqura
  Japanese
  Persian
  Roc
}

/// A calendar-specific era.
pub type Era {
  CommonEra
  BeforeCommonEra
  JapaneseEra(name: JapaneseEraName)
  RocEra
  BeforeRocEra
}

/// A named era in the Japanese calendar.
pub type JapaneseEraName {
  Meiji
  Taisho
  Showa
  Heisei
  Reiwa
}

/// A typed calendar field key.
pub type FieldKey {
  EraField
  EraYearField
  YearField
  MonthField
  MonthCodeField
  DayField
}

/// Optional fields accepted by calendar operations.
pub type CalendarFields {
  CalendarFields(
    era: Option(Era),
    era_year: Option(Int),
    year: Option(Int),
    month: Option(Int),
    month_code: Option(String),
    day: Option(Int),
  )
}

/// Typed ISO date fields.
pub type IsoDateFields {
  IsoDateFields(year: Int, month: Int, day: Int)
}

/// The Temporal shape being produced from calendar fields.
pub type CalendarFieldType {
  DateFields
  YearMonthFields
  MonthDayFields
}

/// Return the built-in ISO 8601 calendar.
pub fn iso_8601() -> Calendar {
  Iso8601
}

/// Parse a calendar identifier from its spec string.
///
/// Identifiers are matched case-insensitively. The core package accepts only
/// the ISO 8601 identifier; other identifiers return `UnknownCalendar`.
pub fn from_string(id: String) -> Result(Calendar, temporal.Error) {
  case string.lowercase(id) {
    "iso8601" -> Ok(iso_8601())
    _ -> Error(temporal.UnknownCalendar(id))
  }
}

/// Parse a calendar identifier.
///
/// This is the identifier-named form of `from_string`.
pub fn from_id(id: String) -> Result(Calendar, temporal.Error) {
  from_string(id)
}

/// Return the canonical calendar identifier.
pub fn to_string(calendar: Calendar) -> String {
  case calendar {
    Iso8601 -> "iso8601"
    Buddhist -> "buddhist"
    Chinese -> "chinese"
    Coptic -> "coptic"
    Dangi -> "dangi"
    Ethioaa -> "ethioaa"
    Ethiopian -> "ethiopic"
    Gregory -> "gregory"
    Hebrew -> "hebrew"
    Indian -> "indian"
    Islamic -> "islamic"
    IslamicCivil -> "islamic-civil"
    IslamicRgsa -> "islamic-rgsa"
    IslamicTabular -> "islamic-tbla"
    IslamicUmalqura -> "islamic-umalqura"
    Japanese -> "japanese"
    Persian -> "persian"
    Roc -> "roc"
  }
}

/// Return the canonical calendar identifier.
///
/// This is the identifier-named form of `to_string`.
pub fn id(calendar: Calendar) -> String {
  to_string(calendar)
}

/// Return whether two calendar variants are equal.
pub fn equal(first: Calendar, second: Calendar) -> Bool {
  first == second
}

/// Prepare typed fields for a calendar operation.
pub fn prepare_fields(
  _calendar: Calendar,
  fields: CalendarFields,
) -> Result(CalendarFields, temporal.Error) {
  Ok(fields)
}

/// Return the typed keys present in a calendar field record.
pub fn field_keys_present(fields: CalendarFields) -> List(FieldKey) {
  []
  |> prepend_if_present(fields.day, DayField)
  |> prepend_if_present(fields.month_code, MonthCodeField)
  |> prepend_if_present(fields.month, MonthField)
  |> prepend_if_present(fields.year, YearField)
  |> prepend_if_present(fields.era_year, EraYearField)
  |> prepend_if_present(fields.era, EraField)
}

/// Merge two typed calendar field records.
pub fn merge_fields(
  calendar: Calendar,
  fields: CalendarFields,
  additional_fields: CalendarFields,
) -> Result(CalendarFields, temporal.Error) {
  let ignored =
    field_keys_to_ignore(calendar, field_keys_present(additional_fields))
  let #(month, month_code) = case
    additional_fields.month,
    additional_fields.month_code
  {
    None, None -> #(fields.month, fields.month_code)
    month, month_code -> #(month, month_code)
  }

  Ok(CalendarFields(
    era: prefer_present(
      additional_fields.era,
      clear_if_ignored(fields.era, ignored, EraField),
    ),
    era_year: prefer_present(
      additional_fields.era_year,
      clear_if_ignored(fields.era_year, ignored, EraYearField),
    ),
    year: prefer_present(
      additional_fields.year,
      clear_if_ignored(fields.year, ignored, YearField),
    ),
    month: month,
    month_code: month_code,
    day: prefer_present(additional_fields.day, fields.day),
  ))
}

/// Add a date duration using a non-ISO calendar provider.
pub fn non_iso_date_add(
  _calendar: Calendar,
  iso_date: IsoDateFields,
  value: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(IsoDateFields, temporal.Error) {
  use _ <- result_try(validate_date_duration(value))
  use date <- result_try(regulate_iso_date(iso_date, temporal.Reject))
  let sign = duration_sign(value)
  use added <- result_try(iso_plain.add_date(
    date,
    value.years * sign,
    value.months * sign,
    value.weeks * sign,
    value.days * sign,
    overflow,
  ))
  Ok(iso_date_fields(added))
}

/// Find a date difference using a non-ISO calendar provider.
pub fn non_iso_date_until(
  _calendar: Calendar,
  first: IsoDateFields,
  second: IsoDateFields,
  largest_unit: duration.Unit,
) -> Result(duration.Duration, temporal.Error) {
  use first <- result_try(regulate_iso_date(first, temporal.Reject))
  use second <- result_try(regulate_iso_date(second, temporal.Reject))
  Ok(duration_from_days(iso_plain.days_between(first, second), largest_unit))
}

/// Convert non-ISO date fields to an ISO date.
pub fn non_iso_date_to_iso(
  _calendar: Calendar,
  fields: CalendarFields,
  overflow: temporal.Overflow,
) -> Result(IsoDateFields, temporal.Error) {
  use year <- result_try(required(fields.year, temporal.Year))
  use month <- result_try(resolve_month(fields.month, fields.month_code))
  use day <- result_try(required(fields.day, temporal.Day))
  use date <- result_try(iso_plain.regulate_date(year, month, day, overflow))
  Ok(iso_date_fields(date))
}

/// Convert non-ISO month-day fields to an ISO reference date.
pub fn non_iso_month_day_to_iso_reference_date(
  calendar: Calendar,
  fields: CalendarFields,
  overflow: temporal.Overflow,
) -> Result(IsoDateFields, temporal.Error) {
  let reference_year = option_or(fields.year, 1972)
  non_iso_date_to_iso(
    calendar,
    CalendarFields(..fields, year: Some(reference_year)),
    overflow,
  )
}

/// Convert an ISO date to non-ISO calendar fields.
pub fn non_iso_iso_to_date(
  _calendar: Calendar,
  iso_date: IsoDateFields,
) -> Result(CalendarFields, temporal.Error) {
  use date <- result_try(regulate_iso_date(iso_date, temporal.Reject))
  let iso_plain.Date(year, month, day) = date
  Ok(CalendarFields(
    era: None,
    era_year: None,
    year: Some(year),
    month: Some(month),
    month_code: Some(month_code(month)),
    day: Some(day),
  ))
}

/// Return extra field keys required by a calendar.
pub fn extra_fields(calendar: Calendar, _keys: List(FieldKey)) -> List(FieldKey) {
  case calendar_has_era(calendar) {
    True -> [EraField, EraYearField]
    False -> []
  }
}

/// Return non-ISO field keys superseded by the supplied keys.
pub fn non_iso_field_keys_to_ignore(
  calendar: Calendar,
  keys: List(FieldKey),
) -> List(FieldKey) {
  case
    calendar_has_era(calendar),
    contains(keys, YearField),
    contains(keys, EraYearField)
  {
    True, True, _ -> [EraYearField]
    True, False, True -> [YearField]
    _, _, _ -> []
  }
}

/// Return field keys superseded by the supplied keys.
pub fn field_keys_to_ignore(
  calendar: Calendar,
  keys: List(FieldKey),
) -> List(FieldKey) {
  let calendar_keys = non_iso_field_keys_to_ignore(calendar, keys)
  case contains(keys, MonthField), contains(keys, MonthCodeField) {
    True, False -> append_unique(calendar_keys, MonthCodeField)
    False, True -> append_unique(calendar_keys, MonthField)
    _, _ -> calendar_keys
  }
}

/// Resolve non-ISO calendar fields for a Temporal shape.
pub fn non_iso_resolve_fields(
  _calendar: Calendar,
  fields: CalendarFields,
  field_type: CalendarFieldType,
) -> Result(CalendarFields, temporal.Error) {
  use month <- result_try(resolve_month(fields.month, fields.month_code))
  let resolved =
    CalendarFields(
      ..fields,
      month: Some(month),
      month_code: Some(month_code(month)),
    )
  case field_type {
    DateFields -> {
      use _ <- result_try(required(resolved.year, temporal.Year))
      use _ <- result_try(required(resolved.day, temporal.Day))
      Ok(resolved)
    }
    YearMonthFields -> {
      use _ <- result_try(required(resolved.year, temporal.Year))
      Ok(CalendarFields(..resolved, day: None))
    }
    MonthDayFields -> {
      use _ <- result_try(required(resolved.day, temporal.Day))
      Ok(CalendarFields(..resolved, year: None, era: None, era_year: None))
    }
  }
}

/// Resolve calendar fields for a Temporal shape.
pub fn resolve_fields(
  calendar: Calendar,
  fields: CalendarFields,
  field_type: CalendarFieldType,
) -> Result(CalendarFields, temporal.Error) {
  case calendar {
    Iso8601 -> Ok(fields)
    _ -> non_iso_resolve_fields(calendar, fields, field_type)
  }
}

/// Convert typed ISO fields to typed calendar fields.
pub fn iso_date_to_fields(
  calendar: Calendar,
  iso_date: IsoDateFields,
  field_type: CalendarFieldType,
) -> Result(CalendarFields, temporal.Error) {
  case calendar {
    Iso8601 -> {
      let fields =
        CalendarFields(
          era: None,
          era_year: None,
          year: Some(iso_date.year),
          month: Some(iso_date.month),
          month_code: Some(month_code(iso_date.month)),
          day: Some(iso_date.day),
        )
      case field_type {
        DateFields -> Ok(fields)
        YearMonthFields -> Ok(CalendarFields(..fields, day: None))
        MonthDayFields -> Ok(CalendarFields(..fields, year: None))
      }
    }
    _ -> {
      use fields <- result_try(non_iso_iso_to_date(calendar, iso_date))
      case field_type {
        DateFields -> Ok(fields)
        YearMonthFields -> Ok(CalendarFields(..fields, day: None))
        MonthDayFields ->
          Ok(CalendarFields(..fields, year: None, era: None, era_year: None))
      }
    }
  }
}

fn validate_date_duration(
  value: duration.Duration,
) -> Result(Nil, temporal.Error) {
  use _ <- result_try(duration.validate(value))
  case
    value.hours == 0
    && value.minutes == 0
    && value.seconds == 0
    && value.milliseconds == 0
    && value.microseconds == 0
    && value.nanoseconds == 0
  {
    True -> Ok(Nil)
    False ->
      Error(temporal.InvalidDuration(
        "calendar date addition does not accept time fields",
      ))
  }
}

fn regulate_iso_date(
  fields: IsoDateFields,
  overflow: temporal.Overflow,
) -> Result(iso_plain.Date, temporal.Error) {
  iso_plain.regulate_date(fields.year, fields.month, fields.day, overflow)
}

fn iso_date_fields(date: iso_plain.Date) -> IsoDateFields {
  let iso_plain.Date(year, month, day) = date
  IsoDateFields(year: year, month: month, day: day)
}

fn duration_sign(value: duration.Duration) -> Int {
  case value.is_negative {
    True -> -1
    False -> 1
  }
}

fn duration_from_days(
  days: Int,
  largest_unit: duration.Unit,
) -> duration.Duration {
  let magnitude = int.absolute_value(days)
  let #(weeks, remaining_days) = case largest_unit {
    duration.Week -> #(magnitude / 7, magnitude % 7)
    _ -> #(0, magnitude)
  }
  duration.Duration(
    is_negative: days < 0,
    years: 0,
    months: 0,
    weeks: weeks,
    days: remaining_days,
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
}

fn required(
  value: Option(Int),
  field: temporal.Field,
) -> Result(Int, temporal.Error) {
  case value {
    Some(value) -> Ok(value)
    None -> Error(temporal.OutOfRange(field, "field is required"))
  }
}

fn resolve_month(
  month: Option(Int),
  code: Option(String),
) -> Result(Int, temporal.Error) {
  case month, code {
    Some(month), None -> Ok(month)
    None, Some(code) -> month_from_code(code)
    Some(month), Some(code) -> {
      use code_month <- result_try(month_from_code(code))
      case month == code_month {
        True -> Ok(month)
        False -> Error(temporal.OutOfRange(temporal.Month, code))
      }
    }
    None, None ->
      Error(temporal.OutOfRange(temporal.Month, "field is required"))
  }
}

fn month_from_code(code: String) -> Result(Int, temporal.Error) {
  case string.starts_with(code, "M") {
    True ->
      case int.parse(string.drop_start(code, 1)) {
        Ok(month) if month >= 1 && month <= 13 -> Ok(month)
        _ -> Error(temporal.OutOfRange(temporal.Month, code))
      }
    False -> Error(temporal.OutOfRange(temporal.Month, code))
  }
}

fn option_or(value: Option(Int), fallback: Int) -> Int {
  case value {
    Some(value) -> value
    None -> fallback
  }
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}

fn prepend_if_present(
  values: List(FieldKey),
  value: Option(a),
  key: FieldKey,
) -> List(FieldKey) {
  case value {
    Some(_) -> [key, ..values]
    None -> values
  }
}

fn prefer_present(preferred: Option(a), fallback: Option(a)) -> Option(a) {
  case preferred {
    Some(_) -> preferred
    None -> fallback
  }
}

fn clear_if_ignored(
  value: Option(a),
  ignored: List(FieldKey),
  key: FieldKey,
) -> Option(a) {
  case contains(ignored, key) {
    True -> None
    False -> value
  }
}

fn calendar_has_era(calendar: Calendar) -> Bool {
  case calendar {
    Buddhist | Coptic | Ethioaa | Ethiopian | Gregory | Japanese | Roc -> True
    _ -> False
  }
}

fn contains(keys: List(FieldKey), key: FieldKey) -> Bool {
  case keys {
    [] -> False
    [first, ..rest] -> first == key || contains(rest, key)
  }
}

fn append_unique(keys: List(FieldKey), key: FieldKey) -> List(FieldKey) {
  case contains(keys, key) {
    True -> keys
    False -> append(keys, key)
  }
}

fn append(keys: List(FieldKey), key: FieldKey) -> List(FieldKey) {
  case keys {
    [] -> [key]
    [first, ..rest] -> [first, ..append(rest, key)]
  }
}

fn month_code(month: Int) -> String {
  case month < 10 {
    True -> "M0" <> int.to_string(month)
    False -> "M" <> int.to_string(month)
  }
}
