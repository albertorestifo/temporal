//// Exact instants paired with a time zone and calendar.
////
//// UTC and fixed offsets support local conversion, ISO calendar arithmetic,
//// differences, rounding, and annotated serialization. Named IANA zones and
//// non-ISO calendars require explicit data providers.

import bigi
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq}
import gleam/string
import temporal
import temporal/calendar
import temporal/duration
import temporal/instant
import temporal/internal/zoned_iso
import temporal/plain_date_time
import temporal/plain_time
import temporal/time_zone

/// An exact instant viewed through a time zone and calendar.
pub opaque type ZonedDateTime {
  ZonedDateTime(
    instant: instant.Instant,
    time_zone: time_zone.TimeZone,
    calendar: calendar.Calendar,
  )
}

/// Optional local fields used by `with_fields`.
pub type PartialZonedDateTime {
  PartialZonedDateTime(
    year: Option(Int),
    month: Option(Int),
    month_code: Option(String),
    day: Option(Int),
    hour: Option(Int),
    minute: Option(Int),
    second: Option(Int),
    millisecond: Option(Int),
    microsecond: Option(Int),
    nanosecond: Option(Int),
    offset: Option(String),
  )
}

/// Parse an annotated Temporal zoned date-time string.
///
/// Named time zones and non-ISO calendars require their corresponding
/// providers.
pub fn from_iso_8601(value: String) -> Result(ZonedDateTime, temporal.Error) {
  case parse_zoned_string(value) {
    Error(_) -> Error(temporal.InvalidIsoString(value))
    Ok(#(date_time_text, offset_text, zone_text, calendar_text)) -> {
      use zone <- result_try(time_zone.from_string(zone_text))
      use calendar_value <- result_try(calendar.from_string(calendar_text))
      use date_time <- result_try(plain_date_time.from_iso_8601(date_time_text))
      use resolved <- result_try(from_plain_date_time(
        date_time,
        zone,
        temporal.Compatible,
      ))
      use actual_offset <- result_try(offset(resolved))
      let supplied_offset = case offset_text {
        "Z" -> "+00:00"
        value -> value
      }
      case supplied_offset == actual_offset {
        True -> Ok(ZonedDateTime(..resolved, calendar: calendar_value))
        False -> Error(temporal.OffsetMismatch)
      }
    }
  }
}

/// Combine an exact instant with a validated time zone and calendar.
///
/// Instants outside Temporal's inclusive ±10^8-day range return `OutOfRange`.
pub fn from_instant(
  value: instant.Instant,
  time_zone time_zone_value: time_zone.TimeZone,
  calendar calendar_value: calendar.Calendar,
) -> Result(ZonedDateTime, temporal.Error) {
  let limit =
    bigi.multiply(
      bigi.from_int(8_640_000_000_000_000),
      bigi.from_int(1_000_000),
    )
  let negative_limit = bigi.multiply(limit, bigi.from_int(-1))
  case
    bigi.compare(value, negative_limit) == order.Lt
    || bigi.compare(value, limit) == order.Gt
  {
    True ->
      Error(temporal.OutOfRange(
        temporal.EpochNanoseconds,
        bigi.to_string(value),
      ))
    False -> Ok(ZonedDateTime(value, time_zone_value, calendar_value))
  }
}

/// Resolve a local date-time in a validated time zone.
///
pub fn from_plain_date_time(
  date_time: plain_date_time.PlainDateTime,
  time_zone_value: time_zone.TimeZone,
  disambiguation: temporal.Disambiguation,
) -> Result(ZonedDateTime, temporal.Error) {
  use possible <- result_try(time_zone.possible_instants_for(
    time_zone_value,
    date_time,
  ))
  case possible, disambiguation {
    [value], _ ->
      from_instant(
        value,
        time_zone: time_zone_value,
        calendar: plain_date_time.calendar(date_time),
      )
    [], temporal.RejectAmbiguous -> Error(temporal.NonexistentLocalTime)
    [], _ -> Error(temporal.NonexistentLocalTime)
    [earlier, ..], temporal.Later -> {
      let last = last_instant(possible, earlier)
      from_instant(
        last,
        time_zone: time_zone_value,
        calendar: plain_date_time.calendar(date_time),
      )
    }
    [_earlier, ..], temporal.RejectAmbiguous ->
      Error(temporal.AmbiguousLocalTime)
    [earlier, ..], _ ->
      from_instant(
        earlier,
        time_zone: time_zone_value,
        calendar: plain_date_time.calendar(date_time),
      )
  }
}

/// Return the exact instant represented by a zoned date-time.
pub fn to_instant(value: ZonedDateTime) -> instant.Instant {
  value.instant
}

/// Return the local ISO date-time represented in this value's time zone.
pub fn to_plain_date_time(
  value: ZonedDateTime,
) -> Result(plain_date_time.PlainDateTime, temporal.Error) {
  use offset <- result_try(offset_nanoseconds(value))
  zoned_iso.to_plain_date_time(value.instant, offset, value.calendar)
}

/// Return the local calendar year.
pub fn year(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.year(local))
}

/// Return the local calendar month.
pub fn month(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.month(local))
}

/// Return the local calendar month code.
pub fn month_code(value: ZonedDateTime) -> Result(String, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.month_code(local))
}

/// Return the local calendar day.
pub fn day(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.day(local))
}

/// Return the local hour.
pub fn hour(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.hour(local))
}

/// Return the local minute.
pub fn minute(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.minute(local))
}

/// Return the local second.
pub fn second(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.second(local))
}

/// Return the local millisecond.
pub fn millisecond(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.millisecond(local))
}

/// Return the local microsecond.
pub fn microsecond(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.microsecond(local))
}

/// Return the local nanosecond.
pub fn nanosecond(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.nanosecond(local))
}

/// Return the calendar-specific era, or `None` for ISO 8601.
pub fn era(value: ZonedDateTime) -> Result(Option(calendar.Era), temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.era(local))
}

/// Return the calendar-specific era year, or `None` for ISO 8601.
pub fn era_year(value: ZonedDateTime) -> Result(Option(Int), temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.era_year(local))
}

/// Return the local ISO day of week.
pub fn day_of_week(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.day_of_week(local))
}

/// Return the local ISO day of year.
pub fn day_of_year(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.day_of_year(local))
}

/// Return the local ISO week number.
pub fn week_of_year(value: ZonedDateTime) -> Result(Option(Int), temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.week_of_year(local))
}

/// Return the local ISO week-numbering year.
pub fn year_of_week(value: ZonedDateTime) -> Result(Option(Int), temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.year_of_week(local))
}

/// Return seven for the ISO calendar.
pub fn days_in_week(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.days_in_week(local))
}

/// Return the number of days in the local month.
pub fn days_in_month(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.days_in_month(local))
}

/// Return the number of days in the local year.
pub fn days_in_year(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.days_in_year(local))
}

/// Return twelve for the ISO calendar.
pub fn months_in_year(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.months_in_year(local))
}

/// Report whether the local ISO year is a leap year.
pub fn in_leap_year(value: ZonedDateTime) -> Result(Bool, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  Ok(plain_date_time.in_leap_year(local))
}

/// Return whole epoch milliseconds, flooring negative sub-milliseconds.
pub fn epoch_milliseconds(value: ZonedDateTime) -> Int {
  let divisor = bigi.from_int(1_000_000)
  let quotient = bigi.divide(value.instant, divisor)
  let remainder = bigi.subtract(value.instant, bigi.multiply(quotient, divisor))
  case bigi.to_int(quotient) {
    Ok(milliseconds) ->
      case bigi.compare(remainder, bigi.from_int(0)) == order.Lt {
        True -> milliseconds - 1
        False -> milliseconds
      }
    Error(_) -> instant.epoch_milliseconds(value.instant)
  }
}

/// Return exact epoch nanoseconds.
pub fn epoch_nanoseconds(value: ZonedDateTime) -> bigi.BigInt {
  value.instant
}

/// Return the time zone attached to this value.
pub fn time_zone(value: ZonedDateTime) -> time_zone.TimeZone {
  value.time_zone
}

/// Return the calendar attached to this value.
pub fn calendar(value: ZonedDateTime) -> calendar.Calendar {
  value.calendar
}

/// Return the UTC offset in nanoseconds at this instant.
pub fn offset_nanoseconds(value: ZonedDateTime) -> Result(Int, temporal.Error) {
  time_zone.offset_nanoseconds_for(value.time_zone, value.instant)
}

/// Return the ISO 8601 UTC offset at this instant.
pub fn offset(value: ZonedDateTime) -> Result(String, temporal.Error) {
  time_zone.offset_iso_8601_for(value.time_zone, value.instant)
}

/// Compare two values by exact instant.
pub fn compare(first: ZonedDateTime, second: ZonedDateTime) -> Order {
  instant.compare(first.instant, second.instant)
}

/// Return whether exact instant, time zone, and calendar all match.
pub fn equal(first: ZonedDateTime, second: ZonedDateTime) -> Bool {
  instant.compare(first.instant, second.instant) == Eq
  && time_zone.equal(first.time_zone, second.time_zone)
  && calendar.equal(first.calendar, second.calendar)
}

/// Replace the supplied local fields.
pub fn with_fields(
  value: ZonedDateTime,
  fields: PartialZonedDateTime,
  overflow: temporal.Overflow,
  disambiguation: temporal.Disambiguation,
  offset_behavior: temporal.OffsetBehavior,
) -> Result(ZonedDateTime, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  let plain_fields =
    plain_date_time.PartialDateTime(
      year: fields.year,
      month: fields.month,
      month_code: fields.month_code,
      day: fields.day,
      hour: fields.hour,
      minute: fields.minute,
      second: fields.second,
      millisecond: fields.millisecond,
      microsecond: fields.microsecond,
      nanosecond: fields.nanosecond,
    )
  use updated <- result_try(plain_date_time.with_fields(
    local,
    plain_fields,
    overflow,
  ))
  case fields.offset, offset_behavior {
    None, _ | _, temporal.Ignore ->
      from_plain_date_time(updated, value.time_zone, disambiguation)
    Some(offset_text), temporal.Use -> {
      use supplied_zone <- result_try(time_zone.from_offset(offset_text))
      use supplied <- result_try(from_plain_date_time(
        updated,
        supplied_zone,
        disambiguation,
      ))
      from_instant(
        supplied.instant,
        time_zone: value.time_zone,
        calendar: value.calendar,
      )
    }
    Some(offset_text), behavior -> {
      use resolved <- result_try(from_plain_date_time(
        updated,
        value.time_zone,
        disambiguation,
      ))
      use actual <- result_try(offset(resolved))
      case actual == offset_text, behavior {
        True, _ -> Ok(resolved)
        False, temporal.Prefer -> Ok(resolved)
        False, temporal.RejectOffset -> Error(temporal.OffsetMismatch)
        False, _ -> Ok(resolved)
      }
    }
  }
}

/// Replace the local time, using midnight when absent.
pub fn with_plain_time(
  value: ZonedDateTime,
  time: Option(plain_time.PlainTime),
) -> Result(ZonedDateTime, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  use updated <- result_try(plain_date_time.with_plain_time(local, time))
  from_plain_date_time(updated, value.time_zone, temporal.Compatible)
}

/// View the same exact instant in another time zone.
pub fn with_time_zone(
  value: ZonedDateTime,
  time_zone_value: time_zone.TimeZone,
) -> Result(ZonedDateTime, temporal.Error) {
  from_instant(
    value.instant,
    time_zone: time_zone_value,
    calendar: value.calendar,
  )
}

/// Replace the calendar while retaining the exact instant and time zone.
pub fn with_calendar(
  value: ZonedDateTime,
  calendar_value: calendar.Calendar,
) -> Result(ZonedDateTime, temporal.Error) {
  from_instant(
    value.instant,
    time_zone: value.time_zone,
    calendar: calendar_value,
  )
}

/// Return the adjacent named-zone transition in a direction.
pub fn get_time_zone_transition(
  value: ZonedDateTime,
  direction: temporal.Direction,
) -> Result(Option(ZonedDateTime), temporal.Error) {
  let transition = case direction {
    temporal.Next -> time_zone.next_transition(value.time_zone, value.instant)
    temporal.Previous ->
      time_zone.previous_transition(value.time_zone, value.instant)
  }
  use possible <- result_try(transition)
  case possible {
    None -> Ok(None)
    Some(instant) -> {
      use zoned <- result_try(from_instant(
        instant,
        time_zone: value.time_zone,
        calendar: value.calendar,
      ))
      Ok(Some(zoned))
    }
  }
}

/// Add a duration using zoned, calendar-aware arithmetic.
pub fn add(
  value: ZonedDateTime,
  amount: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(ZonedDateTime, temporal.Error) {
  use _ <- result_try(duration.validate(amount))
  use local <- result_try(to_plain_date_time(value))
  use updated <- result_try(plain_date_time.add(local, amount, overflow))
  from_plain_date_time(updated, value.time_zone, temporal.Compatible)
}

/// Subtract a duration using zoned, calendar-aware arithmetic.
pub fn subtract(
  value: ZonedDateTime,
  amount: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(ZonedDateTime, temporal.Error) {
  add(value, duration.negated(amount), overflow)
}

/// Return the elapsed duration until another zoned date-time.
pub fn until(
  first: ZonedDateTime,
  second: ZonedDateTime,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  case calendar.equal(first.calendar, second.calendar) {
    False -> Error(temporal.InvalidOption(temporal.DifferenceOptions))
    True -> zoned_iso.difference(first.instant, second.instant, options)
  }
}

/// Return the elapsed duration since another zoned date-time.
pub fn since(
  first: ZonedDateTime,
  second: ZonedDateTime,
  options: duration.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error) {
  until(second, first, options)
}

/// Round a zoned date-time to an increment of a unit.
pub fn round(
  value: ZonedDateTime,
  smallest_unit: duration.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(ZonedDateTime, temporal.Error) {
  case smallest_unit {
    duration.Year | duration.Month | duration.Week ->
      Error(temporal.InvalidOption(temporal.RoundingIncrementOption))
    _ -> {
      use offset <- result_try(offset_nanoseconds(value))
      let local_epoch = bigi.add(value.instant, bigi.from_int(offset))
      use rounded_local <- result_try(zoned_iso.round_epoch(
        local_epoch,
        smallest_unit,
        rounding_increment,
        rounding_mode,
      ))
      let rounded = bigi.subtract(rounded_local, bigi.from_int(offset))
      use instant <- result_try(case instant.from_epoch_nanoseconds(rounded) {
        Ok(value) -> Ok(value)
        Error(_) ->
          Error(temporal.OutOfRange(
            temporal.EpochNanoseconds,
            bigi.to_string(rounded),
          ))
      })
      from_instant(
        instant,
        time_zone: value.time_zone,
        calendar: value.calendar,
      )
    }
  }
}

/// Return the start of the local calendar day.
pub fn start_of_day(
  value: ZonedDateTime,
) -> Result(ZonedDateTime, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  use midnight <- result_try(plain_date_time.with_plain_time(local, None))
  from_plain_date_time(midnight, value.time_zone, temporal.Compatible)
}

/// Return the length of the local day in hours.
///
/// UTC and fixed-offset days are always 24 hours. Named zones require
/// transition data.
pub fn hours_in_day(value: ZonedDateTime) -> Result(Float, temporal.Error) {
  use _ <- result_try(offset_nanoseconds(value))
  Ok(24.0)
}

/// Serialize a zoned date-time in annotated ISO 8601 form.
pub fn to_iso_8601(value: ZonedDateTime) -> Result(String, temporal.Error) {
  use local <- result_try(to_plain_date_time(value))
  use offset <- result_try(offset(value))
  let calendar_annotation = case value.calendar {
    calendar.Iso8601 -> ""
    other -> "[u-ca=" <> calendar.to_string(other) <> "]"
  }
  Ok(
    plain_date_time.to_iso_8601(local)
    <> offset
    <> "["
    <> time_zone.to_string(value.time_zone)
    <> "]"
    <> calendar_annotation,
  )
}

/// Serialize with explicit precision and annotation display options.
pub fn to_iso_8601_with_options(
  value: ZonedDateTime,
  options: duration.ToStringOptions,
) -> Result(String, temporal.Error) {
  let duration.ToStringOptions(
    precision:,
    smallest_unit:,
    rounding_mode:,
    calendar_name:,
    time_zone_name:,
    offset: offset_display,
  ) = options
  use shown <- result_try(case smallest_unit {
    None -> Ok(value)
    Some(unit) ->
      case unit {
        duration.Minute
        | duration.Second
        | duration.Millisecond
        | duration.Microsecond
        | duration.Nanosecond -> round(value, unit, 1, rounding_mode)
        _ -> Error(temporal.InvalidOption(temporal.ToStringOptions))
      }
  })
  use local <- result_try(to_plain_date_time(shown))
  use local_text <- result_try(format_local(local, precision, smallest_unit))
  use offset_text <- result_try(offset(shown))
  let shown_offset = case offset_display {
    duration.Never -> ""
    _ -> offset_text
  }
  let shown_zone = case time_zone_name {
    duration.Never -> ""
    duration.Critical -> "[!" <> time_zone.to_string(shown.time_zone) <> "]"
    _ -> "[" <> time_zone.to_string(shown.time_zone) <> "]"
  }
  let shown_calendar = case calendar_name, shown.calendar {
    duration.Never, _ | duration.Auto, calendar.Iso8601 -> ""
    duration.Critical, calendar_value ->
      "[!u-ca=" <> calendar.to_string(calendar_value) <> "]"
    _, calendar_value -> "[u-ca=" <> calendar.to_string(calendar_value) <> "]"
  }
  Ok(local_text <> shown_offset <> shown_zone <> shown_calendar)
}

fn format_local(
  local: plain_date_time.PlainDateTime,
  precision: duration.Precision,
  smallest_unit: Option(duration.Unit),
) -> Result(String, temporal.Error) {
  let original = plain_date_time.to_iso_8601(local)
  let date = case string.split(original, "T") {
    [date, _] -> date
    _ -> ""
  }
  let hour = pad2(plain_date_time.hour(local))
  let minute = pad2(plain_date_time.minute(local))
  let second = pad2(plain_date_time.second(local))
  let fraction =
    pad3(plain_date_time.millisecond(local))
    <> pad3(plain_date_time.microsecond(local))
    <> pad3(plain_date_time.nanosecond(local))
  let digits = case smallest_unit {
    Some(duration.Minute) -> -1
    Some(duration.Second) -> 0
    Some(duration.Millisecond) -> 3
    Some(duration.Microsecond) -> 6
    Some(duration.Nanosecond) -> 9
    Some(_) -> -2
    None ->
      case precision {
        duration.AutoPrecision -> -3
        duration.Digits(value) if value < 0 -> -4
        duration.Digits(value) -> value
      }
  }
  case digits {
    value if value < -3 || value > 9 ->
      Error(temporal.InvalidOption(temporal.ToStringOptions))
    -3 -> Ok(original)
    -1 -> Ok(date <> "T" <> hour <> ":" <> minute)
    0 -> Ok(date <> "T" <> hour <> ":" <> minute <> ":" <> second)
    count ->
      Ok(
        date
        <> "T"
        <> hour
        <> ":"
        <> minute
        <> ":"
        <> second
        <> "."
        <> take_characters(fraction, count),
      )
  }
}

fn pad2(value: Int) -> String {
  string.pad_start(int.to_string(value), 2, "0")
}

fn pad3(value: Int) -> String {
  string.pad_start(int.to_string(value), 3, "0")
}

fn take_characters(value: String, count: Int) -> String {
  value |> string.to_graphemes() |> list.take(count) |> string.join("")
}

fn parse_zoned_string(
  value: String,
) -> Result(#(String, String, String, String), Nil) {
  case string.split(value, "[") {
    [main, zone_annotation] -> {
      use zone <- nil_try(strip_annotation(zone_annotation))
      use #(date_time, offset) <- nil_try(split_offset(main))
      Ok(#(date_time, offset, zone, "iso8601"))
    }
    [main, zone_annotation, calendar_annotation] -> {
      use zone <- nil_try(strip_annotation(zone_annotation))
      use calendar <- nil_try(strip_calendar_annotation(calendar_annotation))
      use #(date_time, offset) <- nil_try(split_offset(main))
      Ok(#(date_time, offset, zone, calendar))
    }
    _ -> Error(Nil)
  }
}

fn strip_annotation(value: String) -> Result(String, Nil) {
  case string.ends_with(value, "]") {
    True -> Ok(string.drop_end(value, 1))
    False -> Error(Nil)
  }
}

fn strip_calendar_annotation(value: String) -> Result(String, Nil) {
  use annotation <- nil_try(strip_annotation(value))
  case string.starts_with(annotation, "u-ca=") {
    True -> Ok(string.drop_start(annotation, 5))
    False -> Error(Nil)
  }
}

fn split_offset(value: String) -> Result(#(String, String), Nil) {
  case string.ends_with(value, "Z") {
    True -> Ok(#(string.drop_end(value, 1), "Z"))
    False ->
      case string.length(value) >= 6 {
        False -> Error(Nil)
        True -> {
          let offset = string.drop_start(value, string.length(value) - 6)
          case time_zone.from_offset(offset) {
            Ok(_) -> Ok(#(string.drop_end(value, 6), offset))
            Error(_) -> Error(Nil)
          }
        }
      }
  }
}

fn last_instant(
  values: List(instant.Instant),
  fallback: instant.Instant,
) -> instant.Instant {
  case values {
    [] -> fallback
    [value] -> value
    [_, ..rest] -> last_instant(rest, fallback)
  }
}

fn result_try(result: Result(a, e), next: fn(a) -> Result(b, e)) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}

fn nil_try(
  result: Result(a, Nil),
  next: fn(a) -> Result(b, Nil),
) -> Result(b, Nil) {
  case result {
    Ok(value) -> next(value)
    Error(error) -> Error(error)
  }
}
