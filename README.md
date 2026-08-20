# temporal

[![Built with Gleam](https://img.shields.io/badge/built%20with-gleam-ffaff3)](https://gleam.run)
[![Targets](https://img.shields.io/badge/targets-erlang%20%C2%B7%20javascript-a6f0fc)](#development)
[![Temporal pin](https://img.shields.io/badge/temporal%20pin-e8cc03f-lightgrey)](https://github.com/tc39/proposal-temporal/commit/e8cc03fc970a65a3359e8870e3b35e687ac94e55)

A semantic port of [TC39 Temporal](https://tc39.es/proposal-temporal/) to Gleam.

Temporal fixes JavaScript dates by separating exact instants from wall-clock
values, making every value immutable, and making time zones and calendars
explicit. This package keeps those semantics and the observables you rely on —
ISO 8601 strings, the same field names, the same operation set — while dropping
the JavaScript object model. There are no prototypes, no property bags, no
coercion, no `undefined`, and no legacy `Date`. Instead you get modules,
opaque types with validating constructors, closed variant types for options,
`gleam/order.Order` for comparisons, and `Result(value, temporal.Error)` for
everything that can fail.

It compiles and behaves the same on both Erlang and JavaScript. Exact epoch
nanoseconds are kept in [`bigi`](https://hexdocs.pm/bigi/) so the full Temporal
range is safe on both targets.

```gleam
import temporal
import temporal/duration
import temporal/instant

pub fn main() {
  let assert Ok(departure) = instant.from_iso_8601("2020-01-09T00:00Z")
  let assert Ok(arrival) = instant.from_iso_8601("2020-01-09T04:00Z")

  let assert Ok(elapsed) =
    instant.until(
      departure,
      arrival,
      duration.DifferenceOptions(
        largest_unit: duration.Hour,
        smallest_unit: duration.Nanosecond,
        rounding_increment: 1,
        rounding_mode: temporal.Trunc,
      ),
    )

  duration.to_iso_8601(elapsed)
  // -> "PT4H"
}
```

## Install

```sh
gleam add temporal
```

The name `temporal` on Hex is currently held by an unrelated Elixir package, so
until this package is published under a final name, depend on the repository
directly:

```toml
[dependencies]
temporal = { git = "https://github.com/albertorestifo/temporal", ref = "main" }
```

## Spec compliance

Conformance is tracked against immutable pins, not against "whatever the spec
says today". The pins live in
[`conformance/sources.json`](conformance/sources.json):

| Source | Pin |
| --- | --- |
| `proposal-temporal` spec and docs | [`e8cc03f`](https://github.com/tc39/proposal-temporal/commit/e8cc03fc970a65a3359e8870e3b35e687ac94e55) |
| `test262` | [`3655e74`](https://github.com/tc39/test262/commit/3655e7464de3d52643ecddd4b5f9f4f3e7f62398) |

Every normative clause of the pinned spec has a stable requirement ID and a
coverage record under [`conformance/coverage/`](conformance/coverage). Running
`python3 scripts/check_conformance.py` reports the current state:

```text
Conformance inventory OK: 15 sections, 654 requirements, 521 Gleam tests, 4603 test262 files
```

- **654 normative requirements** across the spec's 15 sections.
- **170 are `n/a-js-runtime`** and stay visible rather than being deleted:
  JavaScript prototypes, property descriptors, symbols, coercion hooks,
  subclassing, legacy `Date`, and the 70 ECMA-402-only clauses. They are not
  applicable to a Gleam library, and pretending otherwise would inflate the
  numbers.
- **484 applicable requirements** each link to independently named Gleam tests.
- **521 named Gleam tests** are referenced by the inventory, and each mapping is
  checked to exist and carry matching requirement and spec provenance.
- **4,603 pinned test262 files** each map to exactly one requirement.
- **525 tests pass on Erlang and 525 pass on JavaScript.** Both targets are
  green, with no target-specific exclusions.

One honest caveat about the numbers: applicable requirements are still recorded
with `coverage_status: active` rather than `complete`. Green tests are evidence
that the covered observables behave correctly, not a claim that every clause is
finished. The inventory, not this README, is authoritative — see
[`conformance/README.md`](conformance/README.md).

### Known limits

These are deliberate and worth knowing before you adopt the package.

**Named IANA time zones are not supported.** `time_zone.from_id` and
`from_string` accept `UTC`, `Z`, and numeric `+HH:MM` / `-HH:MM` offsets only;
an IANA name returns `Error(UnknownTimeZone(id))`. A real TZDB provider is
a separate, versioned concern. Internally there is a small POSIX-style rule
table covering seven EU zones (`Europe/Amsterdam`, `Berlin`, `Brussels`,
`Madrid`, `Paris`, `Rome`, `Vienna`) at `+01:00` / `+02:00` with EU
daylight-saving rules. It exists so that transitions and disambiguation can be
exercised end to end. It is *not* the IANA database: one rule covers the whole
timeline, so instants from before those rules were adopted are not historically
accurate.

**`Instant` is a public alias for `bigi.BigInt`, not an opaque type.** The test
suite constructs instants that way today. [`docs/API.md`](docs/API.md) targets
an opaque `Instant` with a validating boundary, so treat the alias as an
implementation detail that will close, and construct values through
`from_iso_8601`, `from_epoch_milliseconds`, or `from_epoch_nanoseconds`.

**`Utc` is not `+00:00`.** A zero numeric offset parses to `FixedOffset(0)` and
keeps the identifier `+00:00`, which is a distinct zone from `Utc`. Two zoned
date-times can therefore share an instant and still not be `equal` if one is
`UTC` and the other `+00:00`. Parse `"UTC"` or `"Z"` with `time_zone.from_string`,
or call `time_zone.utc()`, when you mean the UTC zone.

**Non-ISO calendars are modeled but not calculated.** `calendar.Calendar` has
all the built-in variants, and operations on them return
`Error(PlatformUnavailable(NonIsoCalendarProvider))` until a calendar-data
provider exists. `calendar.Iso8601` is fully supported.

**Some options are still narrowing.** `plain_time.round` and
`plain_date_time.round` currently keep fields finer than `smallest_unit`, so
they do not yet reproduce Temporal's round-to-hour behavior; round an `Instant`
instead. `plain_date.until` reports days and ignores `largest_unit`.

## Recipes

These are ports of recipes from the pinned
[Temporal cookbook](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md),
translated to this library's API. Every snippet below was compiled and run on
both targets, and the commented results are its real output — apart from the
clock recipes, which show one sample run.

The recipes share these imports and helpers:

```gleam
import gleam/option.{None, Some}
import gleam/result
import temporal
import temporal/calendar
import temporal/duration.{type Duration, Duration}
import temporal/instant
import temporal/now
import temporal/plain_date
import temporal/plain_date_time
import temporal/plain_month_day
import temporal/plain_time
import temporal/time_zone
import temporal/zoned_date_time

/// Exact differences, balanced no coarser than hours.
fn exact() -> duration.DifferenceOptions {
  duration.DifferenceOptions(
    largest_unit: duration.Hour,
    smallest_unit: duration.Nanosecond,
    rounding_increment: 1,
    rounding_mode: temporal.Trunc,
  )
}
```

`Duration` is the one type built from a labeled record literal rather than a
smart constructor. Its integer fields are non-negative magnitudes and
`is_negative` carries the sign, and a zero duration is always
`is_negative: False`. There is deliberately no `duration.new(...)` whose only
job would be filling these fields, so a duration of 775 minutes is:

```gleam
let flight_time =
  Duration(
    is_negative: False,
    years: 0,
    months: 0,
    weeks: 0,
    days: 0,
    hours: 0,
    minutes: 775,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
```

The recipes below reuse a zero literal and record-update syntax to keep the
snippets short:

```gleam
const zero = Duration(
  is_negative: False,
  years: 0,
  months: 0,
  weeks: 0,
  days: 0,
  hours: 0,
  minutes: 0,
  seconds: 0,
  milliseconds: 0,
  microseconds: 0,
  nanoseconds: 0,
)

fn days(count: Int) -> Duration {
  Duration(..zero, days: count)
}

fn months(count: Int) -> Duration {
  Duration(..zero, months: count)
}
```

### [Current date and time](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#current-date-and-time)

`None` asks the clock for its own zone. The system clock discovers the host's
current UTC offset.

```gleam
let assert Ok(today) = now.plain_date_iso(time_zone: None)
plain_date.to_iso_8601(today)
// -> "2026-08-20"

let assert Ok(local) = now.plain_date_time_iso(time_zone: None)
plain_date_time.to_iso_8601(local)
// -> "2026-08-20T15:09:11.088"
```

Reading the clock is a `Result`, and there is no global to monkey-patch in
tests. Pass an explicit `fixed_clock` instead:

```gleam
let assert Ok(epoch) = instant.from_iso_8601("2020-01-03T10:41:51Z")
let assert Ok(berlin) = time_zone.from_offset("+01:00")
let clock = now.fixed_clock(instant: epoch, time_zone: berlin)

let assert Ok(zoned) = now.zoned_date_time_iso_with_clock(clock, time_zone: None)
let assert Ok(text) = zoned_date_time.to_iso_8601(zoned)
text
// -> "2020-01-03T11:41:51+01:00[+01:00]"
```

### [Unix timestamp](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unix-timestamp)

```gleam
let assert Ok(timestamp) = now.instant()

instant.epoch_milliseconds(timestamp)
// -> 1787231351088

instant.epoch_milliseconds(timestamp) / 1000
// -> 1787231351
```

### [Noon on a particular date](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#noon-on-a-particular-date)

Combining a calendar date with a wall-clock time. Every field is explicit and
`overflow` is a variant, never the string `"reject"`.

```gleam
let assert Ok(date) = plain_date.from_iso_8601("2020-05-14")
let assert Ok(noon) =
  plain_time.new(
    hour: 12,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
    nanosecond: 0,
    overflow: temporal.Reject,
  )

let assert Ok(noon_on_date) = plain_date_time.from_date_and_time(date, noon)
plain_date_time.to_iso_8601(noon_on_date)
// -> "2020-05-14T12:00:00"
```

### [Birthday in 2030](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#birthday-in-2030)

```gleam
let assert Ok(birthday) = plain_month_day.from_iso_8601("12-15")
let assert Ok(in_2030) =
  plain_date.from_month_day(birthday, 2030, temporal.Reject)

plain_date.to_iso_8601(in_2030)
// -> "2030-12-15"

plain_date.day_of_week(in_2030)
// -> 7
```

### [Zoned instant from instant and time zone](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#zoned-instant-from-instant-and-time-zone)

An `Instant` always serializes in UTC. Pair it with a zone and a calendar to
get local fields and an annotated string. The cookbook uses `Asia/Seoul`; named
zones need a provider here, so the offset stands in for it.

```gleam
let assert Ok(moment) = instant.from_iso_8601("2020-01-03T10:41:51Z")
instant.to_iso_8601(moment)
// -> "2020-01-03T10:41:51Z"

let assert Ok(seoul) = time_zone.from_offset("+09:00")
let assert Ok(zoned) =
  zoned_date_time.from_instant(
    moment,
    time_zone: seoul,
    calendar: calendar.iso_8601(),
  )

let assert Ok(text) = zoned_date_time.to_iso_8601(zoned)
text
// -> "2020-01-03T19:41:51+09:00[+09:00]"

let assert Ok(offset) = zoned_date_time.offset(zoned)
offset
// -> "+09:00"
```

### [Round a time down to whole hours](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#round-a-time-down-to-whole-hours)

Rounding takes a typed unit, an increment, and a `RoundingMode` variant.

```gleam
let assert Ok(precise) = instant.from_iso_8601("2020-01-03T10:41:51.123456789Z")

let assert Ok(whole_hour) =
  instant.round(precise, duration.Hour, 1, temporal.Floor)
instant.to_iso_8601(whole_hour)
// -> "2020-01-03T10:00:00Z"

let assert Ok(whole_milli) =
  instant.round(precise, duration.Millisecond, 1, temporal.HalfExpand)
instant.to_iso_8601(whole_milli)
// -> "2020-01-03T10:41:51.123Z"
```

### [Unit-constrained duration between two instants](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event)

`largest_unit` decides how the difference is balanced.

```gleam
let assert Ok(start) = instant.from_iso_8601("2020-01-09T00:00Z")
let assert Ok(finish) = instant.from_iso_8601("2020-01-09T04:00Z")

let assert Ok(in_hours) = instant.until(start, finish, exact())
duration.to_iso_8601(in_hours)
// -> "PT4H"

let assert Ok(in_minutes) =
  instant.until(
    start,
    finish,
    duration.DifferenceOptions(..exact(), largest_unit: duration.Minute),
  )
duration.to_iso_8601(in_minutes)
// -> "PT240M"
```

### [How many days until a future date](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#how-many-days-until-a-future-date)

```gleam
let assert Ok(today) = plain_date.from_iso_8601("2026-08-20")
let assert Ok(christmas) = plain_date.from_iso_8601("2026-12-25")

let assert Ok(gap) =
  plain_date.until(
    today,
    christmas,
    duration.DifferenceOptions(..exact(), largest_unit: duration.Day),
  )

gap.days
// -> 127

duration.to_iso_8601(gap)
// -> "P127D"
```

### [Flight arrival, departure, and duration](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#flight-arrivaldepartureduration)

Add a flight time to a zoned departure, then view the result in the destination
zone. Time-zone-aware arithmetic stays on the instant, so switching zones only
changes the local view.

```gleam
let assert Ok(hong_kong) = time_zone.from_offset("+08:00")
let assert Ok(los_angeles) = time_zone.from_offset("-07:00")

let assert Ok(departure_local) =
  plain_date_time.from_iso_8601("2020-03-08T11:55:00")
let assert Ok(departure) =
  zoned_date_time.from_plain_date_time(
    departure_local,
    hong_kong,
    temporal.Compatible,
  )

let assert Ok(arrival) =
  zoned_date_time.add(departure, flight_time, temporal.Constrain)
let assert Ok(arrival_local) =
  zoned_date_time.with_time_zone(arrival, los_angeles)

let assert Ok(text) = zoned_date_time.to_iso_8601(arrival_local)
text
// -> "2020-03-08T09:50:00-07:00[-07:00]"

let assert Ok(flight) = zoned_date_time.until(departure, arrival_local, exact())
duration.to_iso_8601(flight)
// -> "PT12H55M"
```

### [Push back a launch date](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#push-back-a-launch-date)

Add a delay, advance a month, then snap to the first. `with_fields` replaces
Temporal's `with`, and omitted fields are `None` rather than a missing property.

```gleam
fn push_back(
  date: plain_date.PlainDate,
  delay_days: Int,
) -> Result(plain_date.PlainDate, temporal.Error) {
  use delayed <- result.try(plain_date.add(
    date,
    days(delay_days),
    temporal.Constrain,
  ))
  use next_month <- result.try(plain_date.add(
    delayed,
    months(1),
    temporal.Constrain,
  ))

  plain_date.with_fields(
    next_month,
    plain_date.PartialDate(
      year: None,
      month: None,
      month_code: None,
      day: Some(1),
    ),
    temporal.Constrain,
  )
}

let assert Ok(old_launch) = plain_date.from_iso_8601("2019-06-01")

let assert Ok(fifteen_days) = push_back(old_launch, 15)
plain_date.to_iso_8601(fifteen_days)
// -> "2019-07-01"

let assert Ok(sixty_days) = push_back(old_launch, 60)
plain_date.to_iso_8601(sixty_days)
// -> "2019-08-01"
```

### [Schedule a reminder ahead of a record](https://github.com/tc39/proposal-temporal/blob/e8cc03fc970a65a3359e8870e3b35e687ac94e55/docs/cookbook.md#schedule-a-reminder-ahead-of-matching-a-record-setting-duration)

```gleam
// Start of the men's 10,000 metres at the Rio de Janeiro 2016 Olympic Games.
let assert Ok(race_start) = instant.from_iso_8601("2016-08-13T21:27:00-03:00")

// Kenenisa Bekele's world record, and how far ahead to warn the runners.
let record = Duration(..zero, minutes: 26, seconds: 17, milliseconds: 530)
let notice_window = Duration(..zero, minutes: 1)

let assert Ok(record_pace) = instant.add(race_start, record)
let assert Ok(reminder) = instant.subtract(record_pace, notice_window)

instant.to_iso_8601(reminder)
// -> "2016-08-14T00:52:17.530Z"
```

Temporal's cookbook prints `2016-08-14T00:52:17.53Z` here. This package always
serializes a fractional second with three, six, or nine digits, so the same
instant reads `.530`.

### Errors are values

Failures name what went wrong instead of throwing, and the closed variants let
you match exhaustively.

```gleam
time_zone.from_id("Europe/Madrid")
// -> Error(UnknownTimeZone("Europe/Madrid"))

instant.from_iso_8601("not a timestamp")
// -> Error(InvalidIsoString("not a timestamp"))

let assert Ok(zero_offset) = time_zone.from_offset("+00:00")
time_zone.equal(zero_offset, time_zone.utc())
// -> False
```

## Learn more

- [`docs/API.md`](docs/API.md) — the full target public surface, module by
  module, plus the complete mapping from JavaScript names and option strings to
  Gleam functions and variants.
- [`conformance/`](conformance/) — the requirement inventory, coverage records,
  pinned sources, and retained upstream license notices.
- [`AGENTS.md`](AGENTS.md) — naming, typing, and testing conventions for
  contributions.

## Development

```sh
gleam format --check src test        # Formatting
gleam test                           # Erlang
gleam test --target javascript       # JavaScript
python3 scripts/check_conformance.py # Conformance inventory
```

Both targets and the conformance check must pass before a change lands.
Conformance tests carry their requirement ID and pinned spec URL immediately
above them, and a new or renamed test updates the matching
`conformance/coverage/*.json` record in the same change.
