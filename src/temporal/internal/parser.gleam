import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Token {
  EnfOfInput
  Sign(Sign)
  DurationDesignator
  Years(Int)
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

pub fn char(char: String, token: Token) -> Parser {
  fn(chars) {
    use #(_value, rest) <- result.try(read_char(chars, char))
    Ok(#(token, rest))
  }
}

pub fn any_of_chars(want: List(String), token: Token) -> Parser {
  fn(chars) {
    case
      list.find(in: want, one_that: fn(char) {
        result.is_ok(read_char(chars, char))
      })
    {
      Ok(_) ->
        case chars {
          [_char, ..rest] -> Ok(#(token, rest))
          [] -> Error(Nil)
        }

      Error(Nil) -> Error(Nil)
    }
  }
}

pub fn int(
  max_length: Int,
  discriminator: String,
  to_token: fn(Int) -> Token,
) -> Parser {
  fn(chars) {
    use #(value, rest) <- result.try(read_int(chars, max_length, []))
    use #(_char, rest) <- result.try(read_char(rest, discriminator))
    Ok(#(to_token(value), rest))
  }
}

fn read_char(
  chars: List(String),
  want: String,
) -> Result(#(String, List(String)), Nil) {
  case chars {
    [char, ..rest] if want == char -> Ok(#(char, rest))
    _other -> Error(Nil)
  }
}

fn read_int(
  chars: List(String),
  remaining_length: Int,
  acc: List(String),
) -> Result(#(Int, List(String)), Nil) {
  let maybe_digit =
    chars
    |> read_next_char(remaining_length)
    |> result.try(is_digit)

  case maybe_digit {
    Ok(#(digit, remaining_chars)) ->
      read_int(remaining_chars, remaining_length - 1, [digit, ..acc])

    Error(Nil) ->
      acc
      |> parse_int_list()
      |> result.try(fn(val) { Ok(#(val, chars)) })
  }
}

fn read_next_char(
  chars: List(String),
  remaining_length: Int,
) -> Result(#(String, List(String)), Nil) {
  case chars, remaining_length {
    _, 0 -> Error(Nil)
    [], _ -> Error(Nil)
    [char, ..rest], _ -> Ok(#(char, rest))
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
