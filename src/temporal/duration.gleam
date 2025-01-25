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
    hours: Int,
    minutes: Int,
    seconds: Int,
    milliseconds: Int,
    microseconds: Int,
    nanoseconds: Int,
  )
}

type TemporaryDuration {
  TemporaryDuration(
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
  |> tokens_to_temporary_duration(TemporaryDuration(
    is_negative: False,
    years: 0,
    months: 0,
    weeks: 0,
    days: 0,
    hours: 0.0,
    minutes: 0.0,
    seconds: 0.0,
  ))
  |> to_duration()
}

fn tokens_to_temporary_duration(
  tokens: List(p.Token),
  acc: TemporaryDuration,
) -> TemporaryDuration {
  case tokens {
    [] -> acc
    [token, ..rest] ->
      tokens_to_temporary_duration(
        rest,
        token_to_temporary_duration(token, acc),
      )
  }
}

fn token_to_temporary_duration(
  token: p.Token,
  acc: TemporaryDuration,
) -> TemporaryDuration {
  case token {
    p.Sign(p.Negative) -> TemporaryDuration(..acc, is_negative: True)
    p.Sign(p.Positive) -> acc
    p.Designator(_any) -> acc
    p.Years(val) -> TemporaryDuration(..acc, years: val)
    p.Months(val) -> TemporaryDuration(..acc, months: val)
    p.Weeks(val) -> TemporaryDuration(..acc, weeks: val)
    p.Days(val) -> TemporaryDuration(..acc, days: val)
    p.Hours(val) -> TemporaryDuration(..acc, hours: val)
    p.Minutes(val) -> TemporaryDuration(..acc, minutes: val)
    p.Seconds(val) -> TemporaryDuration(..acc, seconds: val)
  }
}

fn to_duration(td: TemporaryDuration) -> Result(Duration, Nil) {
  Duration(
    is_negative: td.is_negative,
    years: td.years,
    months: td.months,
    weeks: td.weeks,
    days: td.days,
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
  |> set_hours(td)
  |> result.try(set_minutes(_, td))
  |> result.try(set_seconds(_, td))
}

fn set_hours(d: Duration, td: TemporaryDuration) -> Result(Duration, Nil) {
  case is_set(td.hours), is_regular(td.hours) {
    // Value is not set, leave blank
    False, _ -> Ok(d)

    // Value is set to a regular float, round it to an integer
    True, True -> Ok(Duration(..d, hours: float.round(td.hours)))

    // Value is set to an irregular float, we need to ensure all other subunits are zero
    // then convert the value to all the other subunits
    _, _ ->
      case td {
        TemporaryDuration(
          minutes: 0.0,
          seconds: 0.0,
          is_negative: _,
          years: _,
          months: _,
          weeks: _,
          days: _,
          hours: _,
        ) -> {
          let assert Ok(h_minutes) = float.modulo(td.hours, 1.0)
          let minutes = h_minutes *. 60.0
          let assert Ok(m_seconds) = float.modulo(minutes, 1.0)
          let seconds = m_seconds *. 60.0
          let assert Ok(s_milliseconds) = float.modulo(seconds, 1.0)
          let milliseconds = s_milliseconds *. 1000.0
          let assert Ok(ms_microseconds) = float.modulo(milliseconds, 1.0)
          let microseconds = ms_microseconds *. 1000.0
          let assert Ok(us_nanoseconds) = float.modulo(microseconds, 1.0)
          let nanoseconds = us_nanoseconds *. 1000.0

          Ok(
            Duration(
              ..d,
              hours: to_base(td.hours),
              minutes: to_base(minutes),
              seconds: to_base(seconds),
              milliseconds: to_base(milliseconds),
              microseconds: to_base(microseconds),
              nanoseconds: to_base(nanoseconds),
            ),
          )
        }

        // Some subunits were set, invalid
        _ -> Error(Nil)
      }
  }
}

fn set_minutes(d: Duration, td: TemporaryDuration) -> Result(Duration, Nil) {
  case is_set(td.minutes), is_regular(td.minutes) {
    // Value is not set, leave blank
    False, _ -> Ok(d)

    // Value is set to a regular float, round it to an integer
    True, True -> Ok(Duration(..d, minutes: float.round(td.minutes)))

    // Value is set to an irregular float, we need to ensure seconds are zero
    // then convert the value to all the other subunits
    _, _ ->
      case td {
        TemporaryDuration(
          seconds: 0.0,
          is_negative: _,
          years: _,
          months: _,
          weeks: _,
          days: _,
          hours: _,
          minutes: _,
        ) -> {
          let assert Ok(m_seconds) = float.modulo(td.minutes, 1.0)
          let seconds = m_seconds *. 60.0
          let assert Ok(s_milliseconds) = float.modulo(seconds, 1.0)
          let milliseconds = s_milliseconds *. 1000.0
          let assert Ok(ms_microseconds) = float.modulo(milliseconds, 1.0)
          let microseconds = ms_microseconds *. 1000.0
          let assert Ok(us_nanoseconds) = float.modulo(microseconds, 1.0)
          let nanoseconds = us_nanoseconds *. 1000.0

          Ok(
            Duration(
              ..d,
              minutes: to_base(td.minutes),
              seconds: to_base(seconds),
              milliseconds: to_base(milliseconds),
              microseconds: to_base(microseconds),
              nanoseconds: to_base(nanoseconds),
            ),
          )
        }

        _ -> Error(Nil)
      }
  }
}

fn set_seconds(d: Duration, td: TemporaryDuration) -> Result(Duration, Nil) {
  case is_set(td.seconds), is_regular(td.seconds) {
    // Value is not set, leave blank
    False, _ -> Ok(d)

    // Value is set to a regular float, round it to an integer
    True, True -> Ok(Duration(..d, seconds: float.round(td.seconds)))

    // Value is set to an irregular float, convert to all the other subunits
    _, _ -> {
      let assert Ok(s_milliseconds) = float.modulo(td.seconds, 1.0)
      let milliseconds = s_milliseconds *. 1000.0
      let assert Ok(ms_microseconds) = float.modulo(milliseconds, 1.0)
      let microseconds = ms_microseconds *. 1000.0
      let assert Ok(us_nanoseconds) = float.modulo(microseconds, 1.0)
      let nanoseconds = us_nanoseconds *. 1000.0

      Ok(
        Duration(
          ..d,
          seconds: to_base(td.seconds),
          milliseconds: to_base(milliseconds),
          microseconds: to_base(microseconds),
          nanoseconds: to_base(nanoseconds),
        ),
      )
    }
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

fn to_base(number: Float) -> Int {
  float.floor(number) |> float.round()
}
