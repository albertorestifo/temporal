import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Token {
  EnfOfInput
  Sign(Sign)
  Designator(Designator)
  Years(Int)
  Months(Int)
  Days(Int)
}

pub type Sign {
  Positive
  Negative
}

pub type Parser =
  fn(List(String)) -> Result(#(Token, List(String)), Nil)

pub type TokenReader {
  Maybe(parser: Parser, default: Token)
  Must(parser: Parser)
}

pub type Designator {
  PositiveDesignator
  NegativeDesignator
  DurationDesignator
  YearDesignator
  MonthOrMinuteDesignator
  DayDesignator
  HourDesignator
  SecondDesignator
}

/// Reads the specified sequence of tokens. If any of the Must parser fails,
/// the parsing stops and returns all the tokens successfully parsed.
///
/// If any of the Maybe parser fails, it will return the default token.
pub fn read_sequence(value: String, sequence: List(TokenReader)) -> List(Token) {
  value
  |> string.to_graphemes()
  |> read_sequence_loop(sequence, [])
}

fn read_sequence_loop(
  chars: List(String),
  sequence: List(TokenReader),
  acc: List(Token),
) -> List(Token) {
  case sequence {
    [] -> list.reverse(acc)

    [Maybe(parser:, default:), ..rest_sequence] ->
      case parser(chars) {
        Ok(#(token, rest_chars)) ->
          read_sequence_loop(rest_chars, rest_sequence, [token, ..acc])

        Error(Nil) -> read_sequence_loop(chars, rest_sequence, [default, ..acc])
      }

    [Must(parser:), ..rest_sequence] ->
      case parser(chars) {
        Ok(#(token, rest_chars)) ->
          read_sequence_loop(rest_chars, rest_sequence, [token, ..acc])

        Error(Nil) -> list.reverse(acc)
      }
  }
}

pub fn designator(d: Designator, to_token: fn(Designator) -> Token) -> Parser {
  fn(chars) {
    chars
    |> read_designator(d)
    |> result.map(fn(res) {
      let #(designator, rest) = res
      #(to_token(designator), rest)
    })
  }
}

pub fn to_designator_token(designator: Designator) -> Token {
  Designator(designator)
}

pub fn int(
  ends_with designator: Designator,
  to_token to_token: fn(Int) -> Token,
) -> Parser {
  fn(chars) {
    use #(value, rest) <- result.try(read_int(chars, []))
    use #(_char, rest) <- result.try(read_designator(rest, designator))
    Ok(#(to_token(value), rest))
  }
}

fn read_designator(
  chars: List(String),
  want: Designator,
) -> Result(#(Designator, List(String)), Nil) {
  case chars {
    [] -> Error(Nil)

    [char, ..rest] ->
      case want, char {
        PositiveDesignator, "+" -> Ok(#(PositiveDesignator, rest))
        NegativeDesignator, "-" -> Ok(#(NegativeDesignator, rest))

        DurationDesignator, "P" -> Ok(#(DurationDesignator, rest))
        DurationDesignator, "p" -> Ok(#(DurationDesignator, rest))

        YearDesignator, "Y" -> Ok(#(YearDesignator, rest))
        YearDesignator, "y" -> Ok(#(YearDesignator, rest))

        MonthOrMinuteDesignator, "M" -> Ok(#(MonthOrMinuteDesignator, rest))
        MonthOrMinuteDesignator, "m" -> Ok(#(MonthOrMinuteDesignator, rest))

        DayDesignator, "D" -> Ok(#(DayDesignator, rest))
        DayDesignator, "d" -> Ok(#(DayDesignator, rest))

        HourDesignator, "H" -> Ok(#(HourDesignator, rest))
        HourDesignator, "h" -> Ok(#(HourDesignator, rest))

        SecondDesignator, "S" -> Ok(#(SecondDesignator, rest))
        SecondDesignator, "s" -> Ok(#(SecondDesignator, rest))

        _, _ -> Error(Nil)
      }
  }
}

fn read_int(
  chars: List(String),
  acc: List(String),
) -> Result(#(Int, List(String)), Nil) {
  let maybe_digit =
    chars
    |> read_next_char()
    |> result.try(is_digit)

  case maybe_digit {
    Ok(#(digit, remaining_chars)) -> read_int(remaining_chars, [digit, ..acc])

    Error(Nil) ->
      acc
      |> parse_int_list()
      |> result.try(fn(val) { Ok(#(val, chars)) })
  }
}

fn read_next_char(chars: List(String)) -> Result(#(String, List(String)), Nil) {
  case chars {
    [] -> Error(Nil)
    [char, ..rest] -> Ok(#(char, rest))
  }
}

fn is_digit(
  char: #(String, List(String)),
) -> Result(#(String, List(String)), Nil) {
  let #(char, rest) = char
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
      Ok(#(char, rest))

    _ -> Error(Nil)
  }
}

fn parse_int_list(number: List(String)) -> Result(Int, Nil) {
  case number {
    [] -> Error(Nil)
    value ->
      value
      |> list.reverse
      |> string.join("")
      |> int.base_parse(10)
  }
}
