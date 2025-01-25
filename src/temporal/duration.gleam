import gleam/float
import gleam/result
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
    is_negative: Bool,
    years: Int,
    months: Int,
    weeks: Int,
    days: Int,
    hours: Float,
    minutes: Float,
    seconds: Float,
  )
}

/// Parse a duration from an ISO 8601 string.
/// If the string is not a valid duration, the result will be Nil.
///
/// NOTE: This function understands strings where weeks and other units are combined, and strings with a single sign
/// character at the start, which are extensions to the ISO 8601 standard described in ISO 8601-2.
///
/// For example, `P3W1D` is understood to mean three weeks and one day, `-P1Y1M` is a negative duration of one year
/// and one month, and `+P1Y1M` is one year and one month.
///
/// If no sign character is present, then the sign is assumed to be positive
pub fn from_iso_8601(value: String) -> Result(Duration, Nil) {
  value
  |> p.read_sequence([
    p.Maybe(parser: p.sign(), default: p.Sign(p.Positive)),
    p.Must(parser: p.designator(p.DurationDesignator, p.to_designator_token)),
    p.Maybe(
      parser: p.int(ends_with: p.YearDesignator, to_token: fn(val) {
        p.Years(val)
      }),
      default: p.Years(0),
    ),
    p.Maybe(
      parser: p.int(ends_with: p.MonthOrMinuteDesignator, to_token: fn(val) {
        p.Months(val)
      }),
      default: p.Months(0),
    ),
    p.Maybe(
      parser: p.int(ends_with: p.WeekDesignator, to_token: fn(val) {
        p.Weeks(val)
      }),
      default: p.Weeks(0),
    ),
    p.Maybe(
      parser: p.int(ends_with: p.DayDesignator, to_token: fn(val) {
        p.Days(val)
      }),
      default: p.Days(0),
    ),
    p.Must(parser: p.designator(p.TimeDesignator, p.to_designator_token)),
    p.Maybe(
      parser: p.float(ends_with: p.HourDesignator, to_token: fn(val) {
        p.Hours(val)
      }),
      default: p.Hours(0.0),
    ),
    p.Maybe(
      parser: p.float(ends_with: p.MonthOrMinuteDesignator, to_token: fn(val) {
        p.Minutes(val)
      }),
      default: p.Minutes(0.0),
    ),
    p.Maybe(
      parser: p.float(ends_with: p.SecondDesignator, to_token: fn(val) {
        p.Seconds(val)
      }),
      default: p.Seconds(0.0),
    ),
  ])
  |> tokens_to_duration(Duration(
    is_negative: False,
    years: 0,
    months: 0,
    weeks: 0,
    days: 0,
    hours: 0.0,
    minutes: 0.0,
    seconds: 0.0,
  ))
  |> validate_hours()
  |> result.try(validate_minutes)
}

fn tokens_to_duration(tokens: List(p.Token), acc: Duration) -> Duration {
  case tokens {
    [] -> acc
    [token, ..rest] -> tokens_to_duration(rest, token_to_duration(token, acc))
  }
}

fn token_to_duration(token: p.Token, acc: Duration) -> Duration {
  case token {
    p.Sign(p.Negative) -> Duration(..acc, is_negative: True)
    p.Sign(p.Positive) -> acc
    p.Designator(_any) -> acc
    p.Years(val) -> Duration(..acc, years: val)
    p.Months(val) -> Duration(..acc, months: val)
    p.Weeks(val) -> Duration(..acc, weeks: val)
    p.Days(val) -> Duration(..acc, days: val)
    p.Hours(val) -> Duration(..acc, hours: val)
    p.Minutes(val) -> Duration(..acc, minutes: val)
    p.Seconds(val) -> Duration(..acc, seconds: val)
  }
}

fn validate_hours(duration: Duration) -> Result(Duration, Nil) {
  case duration, is_set(duration.hours), is_regular(duration.hours) {
    // Value is not set, no need to run any validations
    duration, False, _ -> Ok(duration)

    duration, True, True -> Ok(duration)

    // Value is set to an irregular float, we need to ensure all other subunits are zero
    Duration(
      minutes: 0.0,
      seconds: 0.0,
      years: _,
      months: _,
      weeks: _,
      days: _,
      hours: _,
      is_negative: _,
    ),
      True,
      False
    -> Ok(duration)

    _, _, _ -> Error(Nil)
  }
}

fn validate_minutes(duration: Duration) -> Result(Duration, Nil) {
  case duration, is_set(duration.minutes), is_regular(duration.minutes) {
    // Value is not set, no need to run any validations
    duration, False, _ -> Ok(duration)

    duration, True, True -> Ok(duration)

    // Value is set to an irregular float, we need to ensure all other subunits are zero
    Duration(
      seconds: 0.0,
      years: _,
      months: _,
      weeks: _,
      days: _,
      hours: _,
      minutes: _,
      is_negative: _,
    ),
      True,
      False
    -> Ok(duration)

    _, _, _ -> Error(Nil)
  }
}

fn is_set(number: Float) -> Bool {
  case number {
    0.0 -> False
    _ -> True
  }
}

fn is_regular(number: Float) -> Bool {
  case float.modulo(number, 1.0) {
    Ok(0.0) -> True
    _ -> False
  }
}
