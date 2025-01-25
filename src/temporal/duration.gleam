import temporal/internal/parser as p

/// A Duration represents a duration of time which can be used in date/time arithmetic.
///
/// When printed, a Duration produces a string according to the ISO 8601 notation for durations.
/// The examples in this page use this notation extensively.
///
/// Briefly, the ISO 8601 notation consists of a P character, followed by years, months, weeks, and days,
/// followed by a T character, followed by hours, minutes, and seconds with a decimal part, each with a single-letter
/// suffix that indicates the unit. Any zero components may be omitted.
///
/// For more detailed information, see the ISO 8601 standard or the Wikipedia page.
pub type Duration {
  Duration(
    years: Int,
    months: Int,
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    milliseconds: Int,
    microseconds: Int,
    nanoseconds: Int,
  )
}

pub fn from_iso_8601(value: String) -> Result(Duration, Nil) {
  let tokens =
    p.read_sequence(value, [
      p.Maybe(
        parser: p.char("-", p.Sign(p.Negative)),
        default: p.Sign(p.Positive),
      ),
      p.Must(parser: p.any_of_chars(["P", "p"], p.DurationDesignator)),
    ])

  Error(Nil)
}
