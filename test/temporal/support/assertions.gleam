import gleam/string

pub fn equal_with_context(context: String, got: a, expected: a) -> Nil {
  case got == expected {
    True -> Nil
    False ->
      panic as string.concat([
        context,
        ": got ",
        string.inspect(got),
        ", expected ",
        string.inspect(expected),
      ])
  }
}

pub fn is_ok_with_context(context: String, result: Result(a, e)) -> a {
  case result {
    Ok(value) -> value
    Error(error) ->
      panic as string.concat([
        context,
        ": expected Ok, got Error(",
        string.inspect(error),
        ")",
      ])
  }
}

pub fn is_error_with_context(context: String, result: Result(a, e)) -> e {
  case result {
    Error(error) -> error
    Ok(value) ->
      panic as string.concat([
        context,
        ": expected Error, got Ok(",
        string.inspect(value),
        ")",
      ])
  }
}
