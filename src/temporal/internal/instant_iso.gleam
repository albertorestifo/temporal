//// ISO 8601 parsing and serialization for exact instants.
////
//// Values cross this boundary as epoch nanoseconds, so `temporal/instant`
//// keeps ownership of range validation and of the public error type.

import bigi
import gleam/int
import gleam/order.{Gt, Lt}
import gleam/string

/// How many fractional-second digits a serialized instant carries.
pub type Fraction {
  /// Emit the shortest exact fraction, in groups of three digits.
  AutoFraction
  /// Emit exactly `digits` fractional digits; `0` omits the fraction.
  FixedFraction(digits: Int)
  /// Omit the seconds field, as Temporal does at minute precision.
  MinuteFraction
}

/// Returns the largest epoch nanosecond value Temporal represents.
///
/// The limit is 10^8 days on either side of the epoch, inclusive.
pub fn max_epoch_nanoseconds() -> bigi.BigInt {
  bigi.multiply(bigi.from_int(nanoseconds_per_day), bigi.from_int(100_000_000))
}

/// Returns the smallest epoch nanosecond value Temporal represents.
pub fn min_epoch_nanoseconds() -> bigi.BigInt {
  bigi.negate(max_epoch_nanoseconds())
}

/// Reports whether an epoch nanosecond value is inside Temporal's range.
pub fn is_valid_epoch_nanoseconds(value: bigi.BigInt) -> Bool {
  bigi.compare(value, min_epoch_nanoseconds()) != Lt
  && bigi.compare(value, max_epoch_nanoseconds()) != Gt
}

/// Parses an ISO 8601 date-time carrying `Z` or a numeric UTC offset.
///
/// Returns the epoch nanoseconds the string denotes, without checking
/// Temporal's representable range.
pub fn parse(value: String) -> Result(bigi.BigInt, Nil) {
  let scanner = string.to_graphemes(strip_annotation(value))
  use #(date, scanner) <- try(parse_date(scanner))
  use scanner <- try(parse_separator(scanner))
  use #(time, scanner) <- try(parse_time(scanner))
  use #(offset, scanner) <- try(parse_offset(scanner))
  case scanner {
    [] -> combine(date, time, offset)
    _ -> Error(Nil)
  }
}

/// Serializes epoch nanoseconds as a UTC ISO 8601 string.
///
/// Values outside Temporal's range are clamped so that serialization stays
/// total for the aliased public representation.
pub fn format(nanoseconds: bigi.BigInt, fraction: Fraction) -> String {
  let limited =
    bigi.clamp(nanoseconds, min_epoch_nanoseconds(), max_epoch_nanoseconds())
  let divisor = bigi.from_int(nanoseconds_per_day)
  let day = to_int_or_zero(floor_divide(limited, divisor))
  let within = to_int_or_zero(bigi.modulo(limited, divisor))
  let #(year, month, day_of_month) = civil_from_days(day)
  format_year(year)
  <> "-"
  <> pad(month, 2)
  <> "-"
  <> pad(day_of_month, 2)
  <> "T"
  <> pad(within / 3_600_000_000_000, 2)
  <> ":"
  <> pad(within % 3_600_000_000_000 / 60_000_000_000, 2)
  <> format_seconds(
    within % 60_000_000_000 / 1_000_000_000,
    within % 1_000_000_000,
    fraction,
  )
  <> "Z"
}

const nanoseconds_per_day = 86_400_000_000_000

fn combine(
  date: #(Int, Int, Int),
  time: #(Int, Int, Int, Int),
  offset: Int,
) -> Result(bigi.BigInt, Nil) {
  let #(year, month, day) = date
  let #(hour, minute, second, subsecond) = time
  use _ <- try(check(month >= 1 && month <= 12))
  use _ <- try(check(day >= 1 && day <= days_in_month(year, month)))
  use _ <- try(check(hour <= 23 && minute <= 59 && second <= 60))
  // ISO 8601 admits a leap second that Temporal folds onto :59.
  let seconds =
    days_from_civil(year, month, day)
    * 86_400
    + hour
    * 3600
    + minute
    * 60
    + int.min(second, 59)
  bigi.from_int(seconds)
  |> bigi.multiply(bigi.from_int(1_000_000_000))
  |> bigi.add(bigi.from_int(subsecond - offset))
  |> Ok
}

fn strip_annotation(value: String) -> String {
  case string.split_once(value, "[") {
    Ok(#(before, _)) -> before
    Error(Nil) -> value
  }
}

fn parse_date(
  scanner: List(String),
) -> Result(#(#(Int, Int, Int), List(String)), Nil) {
  use #(year, scanner) <- try(parse_year(scanner))
  case scanner {
    ["-", ..tail] -> {
      use #(month, scanner) <- try(take_digits(tail, 2))
      use scanner <- try(expect(scanner, "-"))
      use #(day, scanner) <- try(take_digits(scanner, 2))
      Ok(#(#(year, month, day), scanner))
    }
    _ -> {
      use #(month, scanner) <- try(take_digits(scanner, 2))
      use #(day, scanner) <- try(take_digits(scanner, 2))
      Ok(#(#(year, month, day), scanner))
    }
  }
}

fn parse_year(scanner: List(String)) -> Result(#(Int, List(String)), Nil) {
  case scanner {
    ["+", ..tail] -> take_digits(tail, 6)
    ["-", ..tail] | ["\u{2212}", ..tail] -> {
      use #(year, scanner) <- try(take_digits(tail, 6))
      // Temporal has no negative zero year.
      case year {
        0 -> Error(Nil)
        _ -> Ok(#(-year, scanner))
      }
    }
    _ -> take_digits(scanner, 4)
  }
}

fn parse_separator(scanner: List(String)) -> Result(List(String), Nil) {
  case scanner {
    ["T", ..tail] | ["t", ..tail] | [" ", ..tail] -> Ok(tail)
    _ -> Error(Nil)
  }
}

fn parse_time(
  scanner: List(String),
) -> Result(#(#(Int, Int, Int, Int), List(String)), Nil) {
  use #(hour, scanner) <- try(take_digits(scanner, 2))
  case scanner {
    [":", ..tail] -> {
      use #(minute, scanner) <- try(take_digits(tail, 2))
      case scanner {
        [":", ..tail] -> {
          use #(second, scanner) <- try(take_digits(tail, 2))
          use #(subsecond, scanner) <- try(parse_subsecond(scanner))
          Ok(#(#(hour, minute, second, subsecond), scanner))
        }
        _ -> Ok(#(#(hour, minute, 0, 0), scanner))
      }
    }
    _ ->
      case starts_with_digit(scanner) {
        False -> Ok(#(#(hour, 0, 0, 0), scanner))
        True -> {
          use #(minute, scanner) <- try(take_digits(scanner, 2))
          case starts_with_digit(scanner) {
            False -> Ok(#(#(hour, minute, 0, 0), scanner))
            True -> {
              use #(second, scanner) <- try(take_digits(scanner, 2))
              use #(subsecond, scanner) <- try(parse_subsecond(scanner))
              Ok(#(#(hour, minute, second, subsecond), scanner))
            }
          }
        }
      }
  }
}

fn parse_offset(scanner: List(String)) -> Result(#(Int, List(String)), Nil) {
  case scanner {
    ["Z", ..tail] | ["z", ..tail] -> Ok(#(0, tail))
    ["+", ..tail] -> parse_offset_magnitude(tail, 1)
    ["-", ..tail] | ["\u{2212}", ..tail] -> parse_offset_magnitude(tail, -1)
    _ -> Error(Nil)
  }
}

fn parse_offset_magnitude(
  scanner: List(String),
  sign: Int,
) -> Result(#(Int, List(String)), Nil) {
  use #(#(hour, minute, second, subsecond), scanner) <- try(parse_time(scanner))
  use _ <- try(check(hour <= 23 && minute <= 59 && second <= 59))
  let magnitude =
    { hour * 3600 + minute * 60 + second } * 1_000_000_000 + subsecond
  Ok(#(sign * magnitude, scanner))
}

fn parse_subsecond(scanner: List(String)) -> Result(#(Int, List(String)), Nil) {
  case scanner {
    [".", ..tail] | [",", ..tail] -> take_subsecond_digits(tail, 0, 0)
    _ -> Ok(#(0, scanner))
  }
}

fn take_subsecond_digits(
  scanner: List(String),
  count: Int,
  accumulator: Int,
) -> Result(#(Int, List(String)), Nil) {
  case scanner {
    [head, ..tail] ->
      case int.parse(head), count < 9 {
        Ok(digit), True ->
          take_subsecond_digits(tail, count + 1, accumulator * 10 + digit)
        Ok(_), False -> Error(Nil)
        Error(Nil), _ -> finish_subsecond(scanner, count, accumulator)
      }
    [] -> finish_subsecond(scanner, count, accumulator)
  }
}

fn finish_subsecond(
  scanner: List(String),
  count: Int,
  accumulator: Int,
) -> Result(#(Int, List(String)), Nil) {
  case count {
    0 -> Error(Nil)
    _ -> Ok(#(accumulator * power_of_ten(9 - count), scanner))
  }
}

fn take_digits(
  scanner: List(String),
  count: Int,
) -> Result(#(Int, List(String)), Nil) {
  take_digits_loop(scanner, count, 0)
}

fn take_digits_loop(
  scanner: List(String),
  remaining: Int,
  accumulator: Int,
) -> Result(#(Int, List(String)), Nil) {
  case remaining, scanner {
    0, _ -> Ok(#(accumulator, scanner))
    _, [head, ..tail] ->
      case int.parse(head) {
        Ok(digit) ->
          take_digits_loop(tail, remaining - 1, accumulator * 10 + digit)
        Error(Nil) -> Error(Nil)
      }
    _, [] -> Error(Nil)
  }
}

fn starts_with_digit(scanner: List(String)) -> Bool {
  case scanner {
    [head, ..] ->
      case int.parse(head) {
        Ok(_) -> True
        Error(Nil) -> False
      }
    [] -> False
  }
}

fn expect(scanner: List(String), character: String) -> Result(List(String), Nil) {
  case scanner {
    [head, ..tail] ->
      case head == character {
        True -> Ok(tail)
        False -> Error(Nil)
      }
    [] -> Error(Nil)
  }
}

fn check(condition: Bool) -> Result(Nil, Nil) {
  case condition {
    True -> Ok(Nil)
    False -> Error(Nil)
  }
}

fn try(result: Result(a, Nil), next: fn(a) -> Result(b, Nil)) -> Result(b, Nil) {
  case result {
    Ok(value) -> next(value)
    Error(Nil) -> Error(Nil)
  }
}

fn format_seconds(second: Int, subsecond: Int, fraction: Fraction) -> String {
  case fraction {
    MinuteFraction -> ""
    AutoFraction -> ":" <> pad(second, 2) <> auto_subsecond(subsecond)
    FixedFraction(digits:) ->
      ":" <> pad(second, 2) <> fixed_subsecond(subsecond, digits)
  }
}

fn auto_subsecond(subsecond: Int) -> String {
  case subsecond {
    0 -> ""
    _ -> "." <> trim_digit_groups(pad(subsecond, 9))
  }
}

fn fixed_subsecond(subsecond: Int, digits: Int) -> String {
  case digits <= 0 {
    True -> ""
    False -> "." <> string.slice(pad(subsecond, 9), 0, int.min(digits, 9))
  }
}

fn trim_digit_groups(digits: String) -> String {
  case string.ends_with(digits, "000") {
    True -> trim_digit_groups(string.drop_end(digits, 3))
    False -> digits
  }
}

fn format_year(year: Int) -> String {
  case year >= 0 && year <= 9999 {
    True -> pad(year, 4)
    False ->
      case year < 0 {
        True -> "-" <> pad(-year, 6)
        False -> "+" <> pad(year, 6)
      }
  }
}

fn pad(value: Int, width: Int) -> String {
  string.pad_start(int.to_string(value), width, "0")
}

// The caller clamps to Temporal's range, where every derived value fits in a
// JavaScript-safe integer.
fn to_int_or_zero(value: bigi.BigInt) -> Int {
  case bigi.to_int(value) {
    Ok(int) -> int
    Error(Nil) -> 0
  }
}

// `bigi.divide` truncates towards zero; instants below the epoch need the
// quotient to fall towards negative infinity.
fn floor_divide(dividend: bigi.BigInt, divisor: bigi.BigInt) -> bigi.BigInt {
  let quotient = bigi.divide(dividend, divisor)
  case bigi.compare(bigi.remainder(dividend, divisor), bigi.zero()) {
    Lt -> bigi.subtract(quotient, bigi.from_int(1))
    _ -> quotient
  }
}

fn is_leap_year(year: Int) -> Bool {
  divisible(year, 4) && { !divisible(year, 100) || divisible(year, 400) }
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

// Howard Hinnant's proleptic-Gregorian civil date algorithms.
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
  let initial_year = year_of_era + era * 400
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
  case month <= 2 {
    True -> #(initial_year + 1, month, day)
    False -> #(initial_year, month, day)
  }
}

fn divisible(value: Int, divisor: Int) -> Bool {
  positive_mod(value, divisor) == 0
}

fn floor_div(value: Int, divisor: Int) -> Int {
  let quotient = value / divisor
  case value < 0 && positive_mod(value, divisor) != 0 {
    True -> quotient - 1
    False -> quotient
  }
}

fn positive_mod(value: Int, divisor: Int) -> Int {
  case int.modulo(value, divisor) {
    Ok(remainder) -> remainder
    Error(Nil) -> 0
  }
}

fn power_of_ten(exponent: Int) -> Int {
  case exponent {
    0 -> 1
    _ -> 10 * power_of_ten(exponent - 1)
  }
}
