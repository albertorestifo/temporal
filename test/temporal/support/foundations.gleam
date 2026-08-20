//// Stubbed §13 Temporal abstract operations used by the foundations tests.
////
//// These declarations pin the shape of the abstract operations while the
//// implementations are still missing, so the conformance tests can be written
//// and fail for the right reason. Every function here returns a placeholder
//// value; nothing in this module is package API.

import temporal
import temporal/duration.{type Duration}

/// ISODateToEpochDays: the epoch day of an ISO calendar date.
pub fn iso_date_to_epoch_days(
  _year: Int,
  _month: Int,
  _day: Int,
) -> Result(Int, temporal.Error) {
  Error(temporal.OutOfRange(field: temporal.IsoDate, value: "not implemented"))
}

/// EpochDaysToEpochMs: epoch milliseconds for an epoch day and a
/// time-within-day in milliseconds.
pub fn epoch_days_to_epoch_milliseconds(
  _day: Int,
  _milliseconds_within_day: Int,
) -> Result(Int, temporal.Error) {
  Error(temporal.OutOfRange(field: temporal.EpochDays, value: "not implemented"))
}

/// BalanceISODate: ISO date fields balanced into `#(year, month, day)`.
pub fn balance_iso_date(_year: Int, _month: Int, _day: Int) -> #(Int, Int, Int) {
  #(0, 0, 0)
}

/// BalanceTime: ISO time fields balanced into
/// `#(day_overflow, hour, minute, second, millisecond, microsecond,
/// nanosecond)`.
pub fn balance_time(
  _hour: Int,
  _minute: Int,
  _second: Int,
  _millisecond: Int,
  _microsecond: Int,
  _nanosecond: Int,
) -> #(Int, Int, Int, Int, Int, Int, Int) {
  #(0, 0, 0, 0, 0, 0, 0)
}

/// BalanceTimeDuration: the time fields of a duration carried into their
/// larger units.
pub fn balance_duration_time(
  _duration: Duration,
) -> Result(Duration, temporal.Error) {
  Error(temporal.InvalidDuration(reason: "not implemented"))
}

/// GetTemporalOverflowOption: the overflow option named by a string.
pub fn overflow_option(
  _value: String,
) -> Result(temporal.Overflow, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.OverflowOption))
}

/// NegateRoundingMode: the rounding mode that a negated quantity uses.
pub fn negate_rounding_mode(
  mode: temporal.RoundingMode,
) -> temporal.RoundingMode {
  mode
}

/// ValidateTemporalRoundingIncrement: whether an increment divides a dividend.
pub fn validate_rounding_increment(
  _increment: Int,
  _dividend: Int,
  _inclusive: Bool,
) -> Result(Nil, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.RoundingIncrementOption))
}

/// RoundNumberToIncrement: a value rounded to a positive increment.
pub fn round_number_to_increment(
  _value: Int,
  _increment: Int,
  _mode: temporal.RoundingMode,
) -> Result(Int, temporal.Error) {
  Error(temporal.InvalidOption(option: temporal.RoundingModeOption))
}

/// FormatFractionalSeconds: subsecond nanoseconds at the requested precision.
pub fn format_fractional_seconds(
  _subsecond_nanoseconds: Int,
  _precision: Int,
) -> String {
  ""
}

/// FormatTimeString: a time at the requested fractional-second precision.
pub fn format_time_string(
  _hour: Int,
  _minute: Int,
  _second: Int,
  _subsecond_nanoseconds: Int,
  _precision: Int,
) -> String {
  ""
}
