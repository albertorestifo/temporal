//// Calendar identifiers used by Temporal values.
////
//// The core package currently provides the ISO 8601 calendar. Additional
//// calendars require an explicit, versioned provider.

import gleam/string
import temporal

/// A supported calendar.
///
/// Each built-in calendar is represented by a variant rather than a string.
/// The core package currently provides only `Iso8601`.
pub type Calendar {
  Iso8601
}

/// Return the built-in ISO 8601 calendar.
pub fn iso_8601() -> Calendar {
  Iso8601
}

/// Parse a calendar identifier from its spec string.
///
/// Identifiers are matched case-insensitively. The core package accepts only
/// `iso8601`; other identifiers return `UnknownCalendar`.
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
