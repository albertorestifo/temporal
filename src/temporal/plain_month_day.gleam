//// ISO 8601 recurring month-day values.

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import temporal
import temporal/calendar
import temporal/internal/iso_plain as iso

/// A validated ISO month-day with a reference year.
pub opaque type PlainMonthDay {
  PlainMonthDay(month: Int, day: Int, reference_year: Int)
}

/// Optional month-day fields used by `with_fields`.
pub type PartialMonthDay {
  PartialMonthDay(
    month: Option(Int),
    month_code: Option(String),
    day: Option(Int),
  )
}

/// Builds an unvalidated month-day fixture for package tests.
@internal
pub fn fixture(
  month month: Int,
  day day: Int,
  reference_year reference_year: Int,
) -> PlainMonthDay {
  PlainMonthDay(month: month, day: day, reference_year: reference_year)
}

/// Constructs an ISO month-day.
pub fn new(
  month month: Int,
  day day: Int,
  reference_year reference_year: Int,
  calendar calendar_value: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainMonthDay, temporal.Error) {
  case calendar_value {
    calendar.Iso8601 -> {
      use date <- result_try(iso.regulate_date(
        reference_year,
        month,
        day,
        overflow,
      ))
      let iso.Date(year, month, day) = date
      Ok(PlainMonthDay(month, day, year))
    }
    _ -> Error(temporal.PlatformUnavailable(temporal.NonIsoCalendarProvider))
  }
}

/// Parses an ISO 8601 month-day.
pub fn from_iso_8601(value: String) -> Result(PlainMonthDay, temporal.Error) {
  case string.split(value, "-") {
    [month, day] ->
      case int.parse(month), int.parse(day) {
        Ok(month), Ok(day) ->
          new(month, day, 1972, calendar.Iso8601, temporal.Reject)
          |> map_parse_error(value)
        _, _ -> Error(temporal.InvalidIsoString(value))
      }
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(year), Ok(month), Ok(day) ->
          new(month, day, year, calendar.Iso8601, temporal.Reject)
          |> map_parse_error(value)
        _, _, _ -> Error(temporal.InvalidIsoString(value))
      }
    _ -> Error(temporal.InvalidIsoString(value))
  }
}

/// Returns the ISO month code.
pub fn month_code(value: PlainMonthDay) -> String {
  month_code_for(value.month)
}

/// Returns the ISO day.
pub fn day(value: PlainMonthDay) -> Int {
  value.day
}

/// Returns the calendar of this month-day.
pub fn calendar(_value: PlainMonthDay) -> calendar.Calendar {
  calendar.Iso8601
}

/// Reports whether two month-day values and calendars are equal.
pub fn equal(first: PlainMonthDay, second: PlainMonthDay) -> Bool {
  first == second
}

/// Replace the supplied month-day fields.
pub fn with_fields(
  value: PlainMonthDay,
  fields: PartialMonthDay,
  overflow: temporal.Overflow,
) -> Result(PlainMonthDay, temporal.Error) {
  case fields.month == None && fields.month_code == None && fields.day == None {
    True -> Error(temporal.OutOfRange(temporal.MonthDay, "no fields"))
    False -> {
      use month <- result_try(resolve_month(
        fields.month,
        fields.month_code,
        value.month,
      ))
      new(
        month,
        option_or(fields.day, value.day),
        value.reference_year,
        calendar.Iso8601,
        overflow,
      )
    }
  }
}

/// Serializes a month-day using ISO 8601.
pub fn to_iso_8601(value: PlainMonthDay) -> String {
  iso.format_month_day(value.month, value.day)
}

fn month_code_for(month: Int) -> String {
  case month {
    1 -> "M01"
    2 -> "M02"
    3 -> "M03"
    4 -> "M04"
    5 -> "M05"
    6 -> "M06"
    7 -> "M07"
    8 -> "M08"
    9 -> "M09"
    10 -> "M10"
    11 -> "M11"
    _ -> "M12"
  }
}

fn month_code_number(code: String) -> Int {
  case code {
    "M01" -> 1
    "M02" -> 2
    "M03" -> 3
    "M04" -> 4
    "M05" -> 5
    "M06" -> 6
    "M07" -> 7
    "M08" -> 8
    "M09" -> 9
    "M10" -> 10
    "M11" -> 11
    "M12" -> 12
    _ -> 0
  }
}

fn resolve_month(
  month: Option(Int),
  code: Option(String),
  fallback: Int,
) -> Result(Int, temporal.Error) {
  case month, code {
    None, None -> Ok(fallback)
    Some(month), None -> Ok(month)
    None, Some(code) ->
      case month_code_number(code) {
        0 -> Error(temporal.OutOfRange(temporal.Month, code))
        month -> Ok(month)
      }
    Some(month), Some(code) ->
      case month_code_number(code) == month {
        True -> Ok(month)
        False -> Error(temporal.OutOfRange(temporal.Month, code))
      }
  }
}

fn option_or(value: Option(a), fallback: a) -> a {
  case value {
    Some(value) -> value
    None -> fallback
  }
}

fn map_parse_error(
  result: Result(a, temporal.Error),
  input: String,
) -> Result(a, temporal.Error) {
  case result {
    Ok(value) -> Ok(value)
    Error(_) -> Error(temporal.InvalidIsoString(input))
  }
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
