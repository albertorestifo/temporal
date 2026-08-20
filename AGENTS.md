# Gleam contributor guide

This repository is a semantic port of TC39 Temporal to Gleam. Preserve
Temporal's useful observables—ISO strings, corresponding field names, and its
operation set—while using Gleam modules, immutable values, `Result`, `Order`,
and explicit optional data. Do not reproduce JavaScript prototypes, property
descriptors, coercion, subclassing, `undefined`, legacy `Date`, or behavior
that exists only in ECMA-402.

The desired public surface is in [`docs/API.md`](docs/API.md). The normative
coverage inventory, pinned sources, and requirement IDs are under
[`conformance/`](conformance/). Treat the API document as the target and the
inventory as the source of conformance scope.

## Language and naming

- Use `snake_case` for modules, functions, arguments, variables, and constants;
  use `PascalCase` for types and variants.
- Keep module path segments singular: `temporal/instant`, not
  `temporal/instants`.
- Give every module-level function complete argument and return annotations,
  including private helpers.
- Prefer short module-qualified names. In `temporal/instant`, write
  `to_iso_8601`, not `instant_to_iso_8601`.
- Name conversions `x_to_y`, shortened when the module supplies `x`:
  `instant.to_zoned_date_time(...)`, `plain_date.to_iso_8601(...)`.
- Use `_from_` for a constructor that names its input representation:
  `from_epoch_milliseconds`, `from_iso_8601`.
- Name three-way comparisons `compare` and return `gleam/order.Order`.
- Treat acronyms as words: `iso`, `utc`, `iana`, and `rfc3339`.
- Use pipelines when they make the transformation order easier to read. Do not
  build a pipeline merely to avoid one clear nested call.

```gleam
// Good
pub fn compare(first: Instant, second: Instant) -> order.Order

// Bad: repeats the module name and returns a JS-style integer sentinel
pub fn compare_instants(first, second) -> Int
```

## Types and construction

Use a public record when all of these are true:

1. Direct construction is useful and intentional.
2. Labeled fields communicate the value better than positional arguments.
3. Exposing the representation does not undermine a required invariant.

Use an opaque custom type plus validating constructors when invalid values
must be unrepresentable. `Instant`, `PlainDate`, `PlainTime`,
`PlainDateTime`, `PlainYearMonth`, `PlainMonthDay`, and `ZonedDateTime`
should have opaque public representations even if an early implementation
temporarily uses an alias. Do not expose backend-specific Erlang or
JavaScript values.

### Closed sets are variants, not strings

When a value is one of a known, closed set, use a Gleam custom type with
variants. Do not store Temporal's JavaScript strings (or other stringly-typed
ids) as the representation. Parse strings only at the input boundary with
`from_string` (or another `from_...` constructor) that returns `Result`.

This applies to calendars, overflow, disambiguation, offset behavior,
rounding modes, units, and other option enumerations. Time-zone *kind* is
likewise a variant (`Utc`, `FixedOffset`); open-ended IANA names are not a
core closed set and must not be a freely constructed `id: String` field.

```gleam
// Good
pub type Calendar {
  Iso8601
}

pub fn from_string(id: String) -> Result(Calendar, temporal.Error)

// Bad: any string is representable; invalid ids are a runtime surprise
pub type Calendar {
  Calendar(id: String)
}
```

Use labeled arguments for constructors with multiple same-typed values:

```gleam
let date = plain_date.new(year: 2026, month: 8, day: 20)
```

Use record-update syntax for immutable internal transformations:

```gleam
let later = InternalDate(..date, day: date.day + 1)
```

Do not introduce type aliases just to rename another type. A public alias is
appropriate only when representation identity is intentional; `Instant`
ultimately needs an opaque boundary around `bigi.BigInt`.

### Duration literals

`Duration` is the deliberate exception to smart-constructor-only types.
Construct ordinary values with its labeled record literal:

```gleam
let duration =
  Duration(
    is_negative: False,
    years: 0,
    months: 0,
    weeks: 0,
    days: 2,
    hours: 3,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
```

Do not add `duration.new(...)` or another factory whose only work is filling
these fields. Constructors that parse or convert a representation, such as
`duration.from_iso_8601`, are useful and remain part of the API.

Duration fields are non-negative magnitudes; `is_negative` carries the sign.
Operations and parsers must return canonical values, including
`is_negative: False` for a zero duration. Validate user-provided literals at
operation boundaries when an invariant matters.

## Errors and optional data

Public fallible operations return `Result(value, temporal.Error)`. While code
is being migrated to the documented error type, `Result(value, Nil)` is an
acceptable temporary internal shape, but new public APIs should not discard
useful failure information.

Use `Option(value)` only for data that may be absent: an optional calendar
annotation, a partial field, or an optional `relative_to` value. Do not use
`Option` to report parse or validation failure. Gleam libraries should not
panic for malformed user input, out-of-range fields, ambiguous local times, or
unsupported identifiers.

```gleam
// Good
pub fn from_iso_8601(value: String) -> Result(Instant, temporal.Error)

// Bad: absence hides why parsing failed
pub fn from_iso_8601(value: String) -> Option(Instant)

// Bad: user input is not a programmer assertion
pub fn from_iso_8601(value: String) -> Instant {
  todo as "panic on invalid input"
}
```

Chain fallible operations with `use` or `gleam/result` functions. Never
`result.unwrap` a value merely to silence an error path. Keep `let assert`,
`panic`, and `todo` out of completed library code; assertions are suitable in
tests when they make failures clearer.

## Modules and boundaries

Public modules follow the Temporal concepts:

- `temporal` — shared public option and error types; no demo `main`.
- `temporal/instant`
- `temporal/duration`
- `temporal/plain_date`
- `temporal/plain_time`
- `temporal/plain_date_time`
- `temporal/plain_year_month`
- `temporal/plain_month_day`
- `temporal/zoned_date_time`
- `temporal/now`
- `temporal/calendar`
- `temporal/time_zone`

Put parsing, ISO arithmetic, balancing, rounding, and backend adapters under
`temporal/internal/*`. A public function in an `internal` module is available
to package tests but is not package API.

The package must compile and behave consistently on Erlang and JavaScript.
Keep exact epoch nanoseconds in `bigi.BigInt`; plain Gleam `Int` is not safe
for that range on JavaScript. Prefer target-neutral Gleam. When platform access
is unavoidable—system time or local zone discovery—provide both Erlang and
JavaScript externals behind one typed internal adapter and test their pure
conversion boundary.

`gleam_stdlib` has no `gleam/time` module. The separate official
`gleam_time` package provides timestamps and Gregorian calendar values, but it
does not implement Temporal's nanosecond range, calendar protocol, IANA
time-zone rules, or disambiguation semantics. Reuse it only after checking that
its precision, range, and semantics match the Temporal requirement; do not
silently substitute its `Timestamp` for `Instant`. Continue using `bigi` for
exact epoch nanoseconds.

## Documentation

- Start public modules with `////` module documentation.
- Put `///` immediately before every public type and function.
- Document units, accepted formats, range limits, normalization, and error
  cases. Do not narrate the implementation.
- Include a small example when labels, options, or return values are not
  obvious.
- Use `//` for implementation rationale and conformance provenance.

```gleam
//// Exact, time-zone-independent points on the UTC timeline.

/// Parse an ISO 8601 string containing a UTC offset.
///
/// Returns `Error(InvalidIsoString(...))` when the input is not a valid
/// Temporal instant.
pub fn from_iso_8601(value: String) -> Result(Instant, temporal.Error)
```

## Tests and conformance

- Put tests under `test/` in a path matching the source module and name files
  `*_test.gleam`.
- Expose each gleeunit case as one named `pub fn ..._test()`. Do not combine
  unrelated cases in loops or one large test; stable names are conformance
  evidence.
- Name the behavior and outcome:
  `instant_compare_returns_less_than_test`, not `compare_test_1`.
- Put provenance immediately above every conformance test. Include the stable
  requirement ID and pinned spec URL; include the pinned test262 path when
  applicable.
- Use helpers for repeated setup and richer assertions, not to hide distinct
  conformance cases.
- Test success, each meaningful error category, limits, and both sides of
  boundaries.
- Keep expected Temporal values explicit. Duration expectations should use
  labeled `Duration(...)` literals.
- Update the matching `conformance/coverage/*.json` record in the same change
  as a new or renamed conformance test.

```gleam
// Requirement: TEMP-S08-SEC-TEMPORAL-INSTANT-COMPARE
// Spec: https://github.com/tc39/proposal-temporal/blob/<pin>/spec/instant.html#sec-temporal.instant.compare
// test262: test/built-ins/Temporal/Instant/compare/exhaustive.js
pub fn instant_compare_returns_less_than_test() {
  // One observable case only.
}
```

Before finishing a code change, run:

```sh
gleam format --check src test
gleam test
python3 scripts/check_conformance.py
```

Add target-specific compilation or tests when changing externals. Do not
rewrite unrelated active-section code or revert another contributor's tests.
