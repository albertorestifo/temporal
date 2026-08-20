//// §13 Temporal abstract operations used by the foundations tests.
////
//// This module keeps the test-facing operation names while delegating every
//// implementation to package code.

import temporal
import temporal/duration.{type Duration}

/// ISODateToEpochDays: the epoch day of an ISO calendar date.
pub fn iso_date_to_epoch_days(
  year: Int,
  month: Int,
  day: Int,
) -> Result(Int, temporal.Error) {
  temporal.iso_date_to_epoch_days(year, month, day)
}

/// EpochDaysToEpochMs: epoch milliseconds for an epoch day and a
/// time-within-day in milliseconds.
pub fn epoch_days_to_epoch_milliseconds(
  day: Int,
  milliseconds_within_day: Int,
) -> Result(Int, temporal.Error) {
  temporal.epoch_days_to_epoch_milliseconds(day, milliseconds_within_day)
}

/// BalanceISODate: ISO date fields balanced into `#(year, month, day)`.
pub fn balance_iso_date(year: Int, month: Int, day: Int) -> #(Int, Int, Int) {
  temporal.balance_iso_date(year, month, day)
}

/// BalanceTime: ISO time fields balanced into
/// `#(day_overflow, hour, minute, second, millisecond, microsecond,
/// nanosecond)`.
pub fn balance_time(
  hour: Int,
  minute: Int,
  second: Int,
  millisecond: Int,
  microsecond: Int,
  nanosecond: Int,
) -> #(Int, Int, Int, Int, Int, Int, Int) {
  temporal.balance_time(
    hour,
    minute,
    second,
    millisecond,
    microsecond,
    nanosecond,
  )
}

/// BalanceTimeDuration: the time fields of a duration carried into their
/// larger units.
pub fn balance_duration_time(
  value: Duration,
) -> Result(Duration, temporal.Error) {
  duration.balance_time(value)
}

/// GetTemporalOverflowOption: the overflow option named by a string.
pub fn overflow_option(
  value: String,
) -> Result(temporal.Overflow, temporal.Error) {
  temporal.overflow_from_string(value)
}

/// NegateRoundingMode: the rounding mode that a negated quantity uses.
pub fn negate_rounding_mode(
  mode: temporal.RoundingMode,
) -> temporal.RoundingMode {
  temporal.negate_rounding_mode(mode)
}

/// ValidateTemporalRoundingIncrement: whether an increment divides a dividend.
pub fn validate_rounding_increment(
  increment: Int,
  dividend: Int,
  inclusive: Bool,
) -> Result(Nil, temporal.Error) {
  temporal.validate_rounding_increment(increment, dividend, inclusive)
}

/// RoundNumberToIncrement: a value rounded to a positive increment.
pub fn round_number_to_increment(
  value: Int,
  increment: Int,
  mode: temporal.RoundingMode,
) -> Result(Int, temporal.Error) {
  temporal.round_number_to_increment(value, increment, mode)
}

/// FormatFractionalSeconds: subsecond nanoseconds at the requested precision.
pub fn format_fractional_seconds(
  subsecond_nanoseconds: Int,
  precision: Int,
) -> String {
  temporal.format_fractional_seconds(subsecond_nanoseconds, precision)
}

/// FormatTimeString: a time at the requested fractional-second precision.
pub fn format_time_string(
  hour: Int,
  minute: Int,
  second: Int,
  subsecond_nanoseconds: Int,
  precision: Int,
) -> String {
  temporal.format_time_string(
    hour,
    minute,
    second,
    subsecond_nanoseconds,
    precision,
  )
}
