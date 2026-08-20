//// Shared option and error types used across the Temporal modules.
////
//// Every fallible public operation in this package reports failure with
//// `Error`, so callers can distinguish parsing problems from range problems
//// without inspecting strings.

import gleam/int
import gleam/list
import gleam/string

/// Why a Temporal operation failed.
///
/// `InvalidIsoString` carries the rejected input, `OutOfRange` names the field
/// and the value that fell outside its documented limits, `InvalidOption`
/// names the option, and `PlatformUnavailable` names the platform operation
/// that could not be performed.
pub type Error {
  InvalidIsoString(input: String)
  OutOfRange(field: Field, value: String)
  InvalidDuration(reason: String)
  InvalidOption(option: OptionKind)
  MissingRelativeTo
  UnknownCalendar(id: String)
  UnknownTimeZone(id: String)
  AmbiguousLocalTime
  NonexistentLocalTime
  OffsetMismatch
  PlatformUnavailable(operation: PlatformOperation)
}

/// A field whose value can fall outside Temporal's supported range.
pub type Field {
  Year
  Month
  Day
  Hour
  Minute
  Second
  Millisecond
  Microsecond
  Nanosecond
  Offset
  EpochMilliseconds
  EpochNanoseconds
  Date
  Time
  YearMonth
  MonthDay
  IsoDate
  EpochDays
}

/// A closed option category that can contain an unsupported value.
pub type OptionKind {
  OverflowOption
  RoundingIncrementOption
  RoundingModeOption
  DifferenceOptions
  ToStringOptions
}

/// A platform-dependent operation that may be unavailable.
pub type PlatformOperation {
  SystemClock
  LocalTimeZoneDiscovery
  ZonedDateTimeFromIso8601
  ZonedDateTimeFromPlainDateTime
  ZonedDateTimeToPlainDateTime
  ZonedDateTimeAdd
  ZonedDateTimeSubtract
  ZonedDateTimeDifference
  ZonedDateTimeRound
  ZonedDateTimeStartOfDay
  ZonedDateTimeHoursInDay
  ZonedDateTimeToIso8601
  NamedTimeZoneProvider
  NonIsoCalendarProvider
}

/// How an operation handles a date or time field that falls outside its
/// valid range.
///
/// `Constrain` clamps the field to the closest valid value; `Reject` fails
/// with `OutOfRange`.
pub type Overflow {
  Constrain
  Reject
}

/// How a local date-time is resolved when the time zone has a gap or overlap.
pub type Disambiguation {
  Compatible
  Earlier
  Later
  RejectAmbiguous
}

/// How an annotated offset participates in local time-zone resolution.
pub type OffsetBehavior {
  Prefer
  Use
  Ignore
  RejectOffset
}

/// Whether a serializable annotation is shown.
pub type Display {
  Auto
  Always
  Never
  Critical
}

/// Direction used when looking up a named time-zone transition.
pub type Direction {
  Next
  Previous
}

/// Fractional-second precision used by serialization.
pub type Precision {
  AutoPrecision
  Digits(Int)
}

/// How a value that sits between two increments is rounded.
///
/// The `Half*` modes apply only to exact ties; every other value rounds to the
/// nearer increment.
pub type RoundingMode {
  Ceil
  Floor
  Trunc
  Expand
  HalfCeil
  HalfFloor
  HalfTrunc
  HalfExpand
  HalfEven
}

/// Converts a valid ISO calendar date to days relative to 1970-01-01.
pub fn iso_date_to_epoch_days(
  year: Int,
  month: Int,
  day: Int,
) -> Result(Int, Error) {
  case
    month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month)
  {
    True -> Ok(days_from_civil(year, month, day))
    False ->
      Error(OutOfRange(field: IsoDate, value: format_iso_date(year, month, day)))
  }
}

/// Converts an epoch day and milliseconds within that day to epoch milliseconds.
pub fn epoch_days_to_epoch_milliseconds(
  day: Int,
  milliseconds_within_day: Int,
) -> Result(Int, Error) {
  case
    day >= -100_000_000
    && day <= 100_000_000
    && milliseconds_within_day >= 0
    && milliseconds_within_day < 86_400_000
  {
    True -> Ok(day * 86_400_000 + milliseconds_within_day)
    False -> Error(OutOfRange(field: EpochDays, value: int.to_string(day)))
  }
}

/// Balances overflowing ISO date fields into a calendar date.
pub fn balance_iso_date(year: Int, month: Int, day: Int) -> #(Int, Int, Int) {
  let month_index = year * 12 + month - 1
  let balanced_year = floor_div(month_index, 12)
  let balanced_month = positive_mod(month_index, 12) + 1
  civil_from_days(days_from_civil(balanced_year, balanced_month, 1) + day - 1)
}

/// Balances clock fields and returns the resulting day overflow and time.
pub fn balance_time(
  hour: Int,
  minute: Int,
  second: Int,
  millisecond: Int,
  microsecond: Int,
  nanosecond: Int,
) -> #(Int, Int, Int, Int, Int, Int, Int) {
  let total =
    hour
    * 3_600_000_000_000
    + minute
    * 60_000_000_000
    + second
    * 1_000_000_000
    + millisecond
    * 1_000_000
    + microsecond
    * 1000
    + nanosecond
  let day = floor_div(total, 86_400_000_000_000)
  let within_day = positive_mod(total, 86_400_000_000_000)
  let hour = within_day / 3_600_000_000_000
  let after_hour = within_day % 3_600_000_000_000
  let minute = after_hour / 60_000_000_000
  let after_minute = after_hour % 60_000_000_000
  let second = after_minute / 1_000_000_000
  let after_second = after_minute % 1_000_000_000
  let millisecond = after_second / 1_000_000
  let after_millisecond = after_second % 1_000_000
  let microsecond = after_millisecond / 1000
  let nanosecond = after_millisecond % 1000
  #(day, hour, minute, second, millisecond, microsecond, nanosecond)
}

/// Parses a Temporal overflow option.
pub fn overflow_from_string(value: String) -> Result(Overflow, Error) {
  case value {
    "constrain" -> Ok(Constrain)
    "reject" -> Ok(Reject)
    _ -> Error(InvalidOption(option: OverflowOption))
  }
}

/// Returns the rounding mode used when the rounded quantity is negated.
pub fn negate_rounding_mode(mode: RoundingMode) -> RoundingMode {
  case mode {
    Ceil -> Floor
    Floor -> Ceil
    HalfCeil -> HalfFloor
    HalfFloor -> HalfCeil
    _ -> mode
  }
}

/// Validates that a positive rounding increment divides the dividend.
pub fn validate_rounding_increment(
  increment: Int,
  dividend: Int,
  inclusive: Bool,
) -> Result(Nil, Error) {
  let maximum = case inclusive {
    True -> dividend
    False -> dividend - 1
  }
  case increment > 0 && increment <= maximum && dividend % increment == 0 {
    True -> Ok(Nil)
    False -> Error(InvalidOption(option: RoundingIncrementOption))
  }
}

/// Rounds an integer to a positive increment with a Temporal rounding mode.
pub fn round_number_to_increment(
  value: Int,
  increment: Int,
  mode: RoundingMode,
) -> Result(Int, Error) {
  case increment > 0 {
    False -> Error(InvalidOption(option: RoundingIncrementOption))
    True -> {
      let negative = value < 0
      let magnitude = int.absolute_value(value)
      let quotient = magnitude / increment
      let remainder = magnitude % increment
      let increase =
        should_increase_rounding(negative, quotient, remainder, increment, mode)
      let rounded = case increase {
        True -> { quotient + 1 } * increment
        False -> quotient * increment
      }
      Ok(case negative {
        True -> 0 - rounded
        False -> rounded
      })
    }
  }
}

/// Formats nanoseconds within a second at the requested precision.
pub fn format_fractional_seconds(
  subsecond_nanoseconds: Int,
  precision: Int,
) -> String {
  case precision <= 0 {
    True -> ""
    False -> {
      let digits =
        subsecond_nanoseconds
        |> int.absolute_value()
        |> int.to_string()
        |> left_pad(9, "0")
        |> take_characters(int.min(precision, 9))
      "." <> digits
    }
  }
}

/// Formats a wall-clock time at the requested fractional-second precision.
pub fn format_time_string(
  hour: Int,
  minute: Int,
  second: Int,
  subsecond_nanoseconds: Int,
  precision: Int,
) -> String {
  pad2(hour)
  <> ":"
  <> pad2(minute)
  <> ":"
  <> pad2(second)
  <> format_fractional_seconds(subsecond_nanoseconds, precision)
}

fn should_increase_rounding(
  negative: Bool,
  quotient: Int,
  remainder: Int,
  increment: Int,
  mode: RoundingMode,
) -> Bool {
  case remainder == 0 {
    True -> False
    False ->
      case mode {
        Trunc -> False
        Expand -> True
        Ceil -> !negative
        Floor -> negative
        HalfExpand -> remainder * 2 >= increment
        HalfTrunc -> remainder * 2 > increment
        HalfCeil ->
          remainder * 2 > increment || remainder * 2 == increment && !negative
        HalfFloor ->
          remainder * 2 > increment || remainder * 2 == increment && negative
        HalfEven ->
          remainder * 2 > increment
          || remainder * 2 == increment
          && quotient % 2 == 1
      }
  }
}

fn is_leap_year(year: Int) -> Bool {
  year % 4 == 0 && { year % 100 != 0 || year % 400 == 0 }
}

fn days_in_month(year: Int, month: Int) -> Int {
  case month {
    2 ->
      case is_leap_year(year) {
        True -> 29
        False -> 28
      }
    4 | 6 | 9 | 11 -> 30
    _ -> 31
  }
}

fn days_from_civil(year: Int, month: Int, day: Int) -> Int {
  let adjusted_year = case month <= 2 {
    True -> year - 1
    False -> year
  }
  let era = floor_div(adjusted_year, 400)
  let year_of_era = adjusted_year - era * 400
  let shifted_month = case month > 2 {
    True -> month - 3
    False -> month + 9
  }
  let day_of_year = floor_div(153 * shifted_month + 2, 5) + day - 1
  let day_of_era =
    year_of_era
    * 365
    + floor_div(year_of_era, 4)
    - floor_div(year_of_era, 100)
    + day_of_year
  era * 146_097 + day_of_era - 719_468
}

fn civil_from_days(days: Int) -> #(Int, Int, Int) {
  let shifted = days + 719_468
  let era = floor_div(shifted, 146_097)
  let day_of_era = shifted - era * 146_097
  let year_of_era =
    floor_div(
      day_of_era
        - floor_div(day_of_era, 1460)
        + floor_div(day_of_era, 36_524)
        - floor_div(day_of_era, 146_096),
      365,
    )
  let year = year_of_era + era * 400
  let day_of_year =
    day_of_era
    - {
      365
      * year_of_era
      + floor_div(year_of_era, 4)
      - floor_div(year_of_era, 100)
    }
  let month_prime = floor_div(5 * day_of_year + 2, 153)
  let day = day_of_year - floor_div(153 * month_prime + 2, 5) + 1
  let month = case month_prime < 10 {
    True -> month_prime + 3
    False -> month_prime - 9
  }
  let year = case month <= 2 {
    True -> year + 1
    False -> year
  }
  #(year, month, day)
}

fn floor_div(value: Int, divisor: Int) -> Int {
  let quotient = value / divisor
  case value < 0 && value % divisor != 0 {
    True -> quotient - 1
    False -> quotient
  }
}

fn positive_mod(value: Int, divisor: Int) -> Int {
  let remainder = value % divisor
  case remainder < 0 {
    True -> remainder + divisor
    False -> remainder
  }
}

fn format_iso_date(year: Int, month: Int, day: Int) -> String {
  int.to_string(year)
  <> "-"
  <> int.to_string(month)
  <> "-"
  <> int.to_string(day)
}

fn pad2(value: Int) -> String {
  value |> int.to_string() |> left_pad(2, "0")
}

fn left_pad(value: String, width: Int, character: String) -> String {
  case string.length(value) >= width {
    True -> value
    False -> left_pad(character <> value, width, character)
  }
}

fn take_characters(value: String, count: Int) -> String {
  value |> string.to_graphemes() |> list.take(count) |> string.join("")
}
