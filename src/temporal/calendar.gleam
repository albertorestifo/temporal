//// Calendar identifiers used by Temporal values.
////
//// The core package currently provides the ISO 8601 calendar. Additional
//// calendars require an explicit, versioned provider.

import gleam/option.{type Option}
import gleam/string
import temporal
import temporal/duration

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
/// built-in identifier; other identifiers return `UnknownCalendar`.
pub fn from_string(id: String) -> Result(Calendar, temporal.Error) {
  case string.lowercase(id) {
    "iso8601" -> Ok(iso_8601())
    "buddhist" -> Ok(Buddhist)
    "chinese" -> Ok(Chinese)
    "coptic" -> Ok(Coptic)
    "dangi" -> Ok(Dangi)
    "ethioaa" -> Ok(Ethioaa)
    "ethiopic" -> Ok(Ethiopian)
    "gregory" -> Ok(Gregory)
    "hebrew" -> Ok(Hebrew)
    "indian" -> Ok(Indian)
    "islamic" -> Ok(Islamic)
    "islamic-civil" -> Ok(IslamicCivil)
    "islamic-rgsa" -> Ok(IslamicRgsa)
    "islamic-tbla" -> Ok(IslamicTabular)
    "islamic-umalqura" -> Ok(IslamicUmalqura)
    "japanese" -> Ok(Japanese)
    "persian" -> Ok(Persian)
    "roc" -> Ok(Roc)
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
  _fields: CalendarFields,
) -> Result(CalendarFields, temporal.Error) {
  unavailable()
}

/// Return the typed keys present in a calendar field record.
pub fn field_keys_present(_fields: CalendarFields) -> List(FieldKey) {
  []
}

/// Merge two typed calendar field records.
pub fn merge_fields(
  _calendar: Calendar,
  _fields: CalendarFields,
  _additional_fields: CalendarFields,
) -> Result(CalendarFields, temporal.Error) {
  unavailable()
}

/// Add a date duration using a non-ISO calendar provider.
pub fn non_iso_date_add(
  _calendar: Calendar,
  _iso_date: IsoDateFields,
  _value: duration.Duration,
  _overflow: temporal.Overflow,
) -> Result(IsoDateFields, temporal.Error) {
  unavailable()
}

/// Find a date difference using a non-ISO calendar provider.
pub fn non_iso_date_until(
  _calendar: Calendar,
  _first: IsoDateFields,
  _second: IsoDateFields,
  _largest_unit: duration.Unit,
) -> Result(duration.Duration, temporal.Error) {
  unavailable()
}

/// Convert non-ISO date fields to an ISO date.
pub fn non_iso_date_to_iso(
  _calendar: Calendar,
  _fields: CalendarFields,
  _overflow: temporal.Overflow,
) -> Result(IsoDateFields, temporal.Error) {
  unavailable()
}

/// Convert non-ISO month-day fields to an ISO reference date.
pub fn non_iso_month_day_to_iso_reference_date(
  _calendar: Calendar,
  _fields: CalendarFields,
  _overflow: temporal.Overflow,
) -> Result(IsoDateFields, temporal.Error) {
  unavailable()
}

/// Convert an ISO date to non-ISO calendar fields.
pub fn non_iso_iso_to_date(
  _calendar: Calendar,
  _iso_date: IsoDateFields,
) -> Result(CalendarFields, temporal.Error) {
  unavailable()
}

/// Return extra field keys required by a calendar.
pub fn extra_fields(
  _calendar: Calendar,
  _keys: List(FieldKey),
) -> List(FieldKey) {
  []
}

/// Return non-ISO field keys superseded by the supplied keys.
pub fn non_iso_field_keys_to_ignore(
  _calendar: Calendar,
  _keys: List(FieldKey),
) -> List(FieldKey) {
  []
}

/// Return field keys superseded by the supplied keys.
pub fn field_keys_to_ignore(
  _calendar: Calendar,
  _keys: List(FieldKey),
) -> List(FieldKey) {
  []
}

/// Resolve non-ISO calendar fields for a Temporal shape.
pub fn non_iso_resolve_fields(
  _calendar: Calendar,
  _fields: CalendarFields,
  _field_type: CalendarFieldType,
) -> Result(CalendarFields, temporal.Error) {
  unavailable()
}

/// Resolve calendar fields for a Temporal shape.
pub fn resolve_fields(
  _calendar: Calendar,
  _fields: CalendarFields,
  _field_type: CalendarFieldType,
) -> Result(CalendarFields, temporal.Error) {
  unavailable()
}

/// Convert typed ISO fields to typed calendar fields.
pub fn iso_date_to_fields(
  _calendar: Calendar,
  _iso_date: IsoDateFields,
  _field_type: CalendarFieldType,
) -> Result(CalendarFields, temporal.Error) {
  unavailable()
}

fn unavailable() -> Result(a, temporal.Error) {
  Error(temporal.PlatformUnavailable(temporal.NonIsoCalendarProvider))
}
