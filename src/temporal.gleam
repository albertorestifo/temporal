//// Shared option and error types used across the Temporal modules.
////
//// Every fallible public operation in this package reports failure with
//// `Error`, so callers can distinguish parsing problems from range problems
//// without inspecting strings.

/// Why a Temporal operation failed.
///
/// `InvalidIsoString` carries the rejected input, `OutOfRange` names the field
/// and the value that fell outside its documented limits, `InvalidOption`
/// names the option and the unsupported value, and `PlatformUnavailable`
/// names the platform operation that could not be performed.
pub type Error {
  InvalidIsoString(input: String)
  OutOfRange(field: String, value: String)
  InvalidDuration(reason: String)
  InvalidOption(name: String, value: String)
  MissingRelativeTo
  UnknownCalendar(id: String)
  UnknownTimeZone(id: String)
  AmbiguousLocalTime
  NonexistentLocalTime
  OffsetMismatch
  PlatformUnavailable(operation: String)
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
