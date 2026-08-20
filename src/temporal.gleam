//// Shared option and error types used across the Temporal modules.
////
//// Every fallible public operation in this package reports failure with
//// `Error`, so callers can distinguish parsing problems from range problems
//// without inspecting strings.

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
  ZonedDateTimeAdd
  ZonedDateTimeSubtract
  ZonedDateTimeStartOfDay
  ZonedDateTimeHoursInDay
  ZonedDateTimeToIso8601
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
