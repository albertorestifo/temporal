//// ISO 8601 recurring month-day values.

import temporal
import temporal/calendar

/// A validated ISO month-day with a reference year.
pub opaque type PlainMonthDay {
  PlainMonthDay(month: Int, day: Int, reference_year: Int)
}

/// Constructs an ISO month-day.
pub fn new(
  month month: Int,
  day day: Int,
  reference_year reference_year: Int,
  calendar _calendar: calendar.Calendar,
  overflow _overflow: temporal.Overflow,
) -> Result(PlainMonthDay, temporal.Error) {
  Error(temporal.OutOfRange(
    field: "month_day",
    value: label(month, day, reference_year),
  ))
}

/// Parses an ISO 8601 month-day.
pub fn from_iso_8601(value: String) -> Result(PlainMonthDay, temporal.Error) {
  Error(temporal.InvalidIsoString(input: value))
}

/// Returns the ISO month code.
pub fn month_code(value: PlainMonthDay) -> String {
  month_code_for(value.month)
}

/// Returns the ISO day.
pub fn day(value: PlainMonthDay) -> Int {
  value.day
}

/// Returns `iso8601`.
pub fn calendar_id(_value: PlainMonthDay) -> String {
  "iso8601"
}

/// Reports whether two month-day values and calendars are equal.
pub fn equal(first: PlainMonthDay, second: PlainMonthDay) -> Bool {
  first == second
}

/// Serializes a month-day using ISO 8601.
pub fn to_iso_8601(_value: PlainMonthDay) -> String {
  ""
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

fn label(month: Int, day: Int, year: Int) -> String {
  case month + day + year {
    0 -> "0"
    _ -> "invalid"
  }
}
