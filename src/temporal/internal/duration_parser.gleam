//// Exact parser for Temporal ISO 8601 duration strings.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// Parsed duration fields plus the fractional part expressed as nanoseconds.
pub type ParsedDuration {
  ParsedDuration(
    is_negative: Bool,
    years: Int,
    months: Int,
    weeks: Int,
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    fractional_nanoseconds: Int,
  )
}

type Section {
  DateSection
  TimeSection
}

type ParseState {
  ParseState(
    section: Section,
    last_rank: Int,
    saw_component: Bool,
    saw_time_designator: Bool,
    saw_time_component: Bool,
    years: Int,
    months: Int,
    weeks: Int,
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    fractional_nanoseconds: Int,
  )
}

/// Parses the case-sensitive Temporal duration grammar.
pub fn parse(value: String) -> Result(ParsedDuration, Nil) {
  let chars = string.to_graphemes(value)
  use #(is_negative, chars) <- result.try(read_sign(chars))
  use chars <- result.try(read_p(chars))
  use state <- result.try(parse_components(
    chars,
    ParseState(
      section: DateSection,
      last_rank: -1,
      saw_component: False,
      saw_time_designator: False,
      saw_time_component: False,
      years: 0,
      months: 0,
      weeks: 0,
      days: 0,
      hours: 0,
      minutes: 0,
      seconds: 0,
      fractional_nanoseconds: 0,
    ),
  ))
  case
    state.saw_component,
    state.saw_time_designator,
    state.saw_time_component
  {
    False, _, _ -> Error(Nil)
    _, True, False -> Error(Nil)
    _, _, _ ->
      Ok(ParsedDuration(
        is_negative: is_negative,
        years: state.years,
        months: state.months,
        weeks: state.weeks,
        days: state.days,
        hours: state.hours,
        minutes: state.minutes,
        seconds: state.seconds,
        fractional_nanoseconds: state.fractional_nanoseconds,
      ))
  }
}

fn read_sign(chars: List(String)) -> Result(#(Bool, List(String)), Nil) {
  case chars {
    ["-", ..rest] -> Ok(#(True, rest))
    ["+", ..rest] -> Ok(#(False, rest))
    _ -> Ok(#(False, chars))
  }
}

fn read_p(chars: List(String)) -> Result(List(String), Nil) {
  case chars {
    ["P", ..rest] -> Ok(rest)
    _ -> Error(Nil)
  }
}

fn parse_components(
  chars: List(String),
  state: ParseState,
) -> Result(ParseState, Nil) {
  case chars {
    [] -> Ok(state)
    ["T", ..rest] ->
      case state.section, state.saw_time_designator {
        DateSection, False ->
          parse_components(
            rest,
            ParseState(
              ..state,
              section: TimeSection,
              last_rank: -1,
              saw_time_designator: True,
            ),
          )
        _, _ -> Error(Nil)
      }
    _ -> {
      use #(whole, fraction, rest) <- result.try(read_number(chars))
      use #(designator, rest) <- result.try(read_designator(rest))
      use next <- result.try(set_component(
        state,
        whole,
        fraction,
        designator,
        list.is_empty(rest),
      ))
      parse_components(rest, next)
    }
  }
}

fn read_number(
  chars: List(String),
) -> Result(#(Int, Option(List(String)), List(String)), Nil) {
  let #(whole_chars, rest) = take_digits(chars, [])
  case whole_chars {
    [] -> Error(Nil)
    _ -> {
      use whole <- result.try(parse_digits(whole_chars))
      case rest {
        [separator, ..fraction_chars] if separator == "." || separator == "," -> {
          let #(digits, rest) = take_digits(fraction_chars, [])
          case digits, list.length(digits) <= 9 {
            [], _ -> Error(Nil)
            _, False -> Error(Nil)
            _, True -> Ok(#(whole, Some(digits), rest))
          }
        }
        _ -> Ok(#(whole, None, rest))
      }
    }
  }
}

fn take_digits(
  chars: List(String),
  acc: List(String),
) -> #(List(String), List(String)) {
  case chars {
    [char, ..rest] ->
      case is_digit(char) {
        True -> take_digits(rest, [char, ..acc])
        False -> #(list.reverse(acc), chars)
      }
    _ -> #(list.reverse(acc), chars)
  }
}

fn is_digit(char: String) -> Bool {
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

fn parse_digits(chars: List(String)) -> Result(Int, Nil) {
  chars |> string.join("") |> int.base_parse(10)
}

fn read_designator(chars: List(String)) -> Result(#(String, List(String)), Nil) {
  case chars {
    [designator, ..rest]
      if designator == "Y"
      || designator == "M"
      || designator == "W"
      || designator == "D"
      || designator == "H"
      || designator == "S"
    -> Ok(#(designator, rest))
    _ -> Error(Nil)
  }
}

fn set_component(
  state: ParseState,
  whole: Int,
  fraction: Option(List(String)),
  designator: String,
  is_last: Bool,
) -> Result(ParseState, Nil) {
  case state.section, designator {
    DateSection, "Y" -> set_date(state, whole, fraction, 0, "Y")
    DateSection, "M" -> set_date(state, whole, fraction, 1, "M")
    DateSection, "W" -> set_date(state, whole, fraction, 2, "W")
    DateSection, "D" -> set_date(state, whole, fraction, 3, "D")
    TimeSection, "H" ->
      set_time(state, whole, fraction, 0, 3_600_000_000_000, is_last)
    TimeSection, "M" ->
      set_time(state, whole, fraction, 1, 60_000_000_000, is_last)
    TimeSection, "S" ->
      set_time(state, whole, fraction, 2, 1_000_000_000, is_last)
    _, _ -> Error(Nil)
  }
}

fn set_date(
  state: ParseState,
  whole: Int,
  fraction: Option(List(String)),
  rank: Int,
  designator: String,
) -> Result(ParseState, Nil) {
  case fraction, rank > state.last_rank {
    Some(_), _ -> Error(Nil)
    _, False -> Error(Nil)
    None, True ->
      case designator {
        "Y" ->
          Ok(
            ParseState(
              ..state,
              last_rank: rank,
              saw_component: True,
              years: whole,
            ),
          )
        "M" ->
          Ok(
            ParseState(
              ..state,
              last_rank: rank,
              saw_component: True,
              months: whole,
            ),
          )
        "W" ->
          Ok(
            ParseState(
              ..state,
              last_rank: rank,
              saw_component: True,
              weeks: whole,
            ),
          )
        "D" ->
          Ok(
            ParseState(
              ..state,
              last_rank: rank,
              saw_component: True,
              days: whole,
            ),
          )
        _ -> Error(Nil)
      }
  }
}

fn set_time(
  state: ParseState,
  whole: Int,
  fraction: Option(List(String)),
  rank: Int,
  unit_nanoseconds: Int,
  is_last: Bool,
) -> Result(ParseState, Nil) {
  case rank > state.last_rank, fraction, is_last {
    False, _, _ -> Error(Nil)
    _, Some(_), False -> Error(Nil)
    True, _, _ -> {
      use fractional_nanoseconds <- result.try(fraction_to_nanoseconds(
        fraction,
        unit_nanoseconds,
      ))
      let updated =
        ParseState(
          ..state,
          last_rank: rank,
          saw_component: True,
          saw_time_component: True,
          fractional_nanoseconds: fractional_nanoseconds,
        )
      case rank {
        0 -> Ok(ParseState(..updated, hours: whole))
        1 -> Ok(ParseState(..updated, minutes: whole))
        2 -> Ok(ParseState(..updated, seconds: whole))
        _ -> Error(Nil)
      }
    }
  }
}

fn fraction_to_nanoseconds(
  fraction: Option(List(String)),
  unit_nanoseconds: Int,
) -> Result(Int, Nil) {
  case fraction {
    None -> Ok(0)
    Some(digits) -> {
      let padded = pad_fraction(digits)
      use numerator <- result.try(parse_digits(padded))
      Ok(numerator * unit_nanoseconds / 1_000_000_000)
    }
  }
}

fn pad_fraction(digits: List(String)) -> List(String) {
  case list.length(digits) {
    9 -> digits
    _ -> pad_fraction(list.append(digits, ["0"]))
  }
}
