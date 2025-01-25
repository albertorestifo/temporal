import gleam/list
import gleam/string
import temporal/duration.{Duration, from_iso_8601}

pub fn from_iso_8601_test() {
  let cases = [
    #(
      "P3W1D",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 3,
        days: 1,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
    #(
      "-P1Y1M",
      Ok(Duration(
        is_negative: True,
        years: 1,
        months: 1,
        weeks: 0,
        days: 0,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
    #(
      "+P1Y1M",
      Ok(Duration(
        is_negative: False,
        years: 1,
        months: 1,
        weeks: 0,
        days: 0,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
    #(
      "P1Y1M1DT1H1M1.1S",
      Ok(Duration(
        is_negative: False,
        years: 1,
        months: 1,
        weeks: 0,
        days: 1,
        hours: 1.0,
        minutes: 1.0,
        seconds: 1.1,
      )),
    ),
    #(
      "P40D",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 40,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
    #(
      "P1Y1D",
      Ok(Duration(
        is_negative: False,
        years: 1,
        months: 0,
        weeks: 0,
        days: 1,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
    #(
      "P3DT4H59M",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 3,
        hours: 4.0,
        minutes: 59.0,
        seconds: 0.0,
      )),
    ),
    #(
      "PT2H30M",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 0,
        hours: 2.0,
        minutes: 30.0,
        seconds: 0.0,
      )),
    ),
    #(
      "P1M",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 1,
        weeks: 0,
        days: 0,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
    #(
      "PT0.0021S",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 0,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0021,
      )),
    ),
    #(
      "PT0S",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 0,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
    #(
      "P0D",
      Ok(Duration(
        is_negative: False,
        years: 0,
        months: 0,
        weeks: 0,
        days: 0,
        hours: 0.0,
        minutes: 0.0,
        seconds: 0.0,
      )),
    ),
  ]

  list.each(cases, fn(the_case) {
    let #(input, expected) = the_case

    equal(input, from_iso_8601(input), expected)
  })
}

fn equal(input: String, got: a, want: a) -> Nil {
  case got == want {
    True -> Nil
    _ ->
      panic as string.concat([
        input,
        " => ",
        string.inspect(got),
        " should equal ",
        string.inspect(want),
      ])
  }
}
