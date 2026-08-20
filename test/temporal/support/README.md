# Temporal test support conventions

Every conformance test is independently named and covers one observable case.
Use a name that remains meaningful in the coverage inventory, for example
`duration_from_rejects_fractional_year_test`. Reference it from coverage as a
fully qualified stable ID such as
`temporal/duration_test::duration_from_rejects_fractional_year_test`.

Immediately above each test, record:

```gleam
// Requirement: TEMP-S07-SEC-TEMPORAL-DURATION-FROM
// Spec: https://github.com/tc39/proposal-temporal/blob/<pinned-sha>/spec/duration.html#sec-temporal.duration.from
// test262: test/built-ins/Temporal/Duration/from/<case>.js
// Example: https://github.com/tc39/proposal-temporal/blob/<pinned-sha>/docs/cookbook.md#<anchor>
```

Omit only provenance lines that do not apply. Never use a moving `main` or
`master` URL. Put reusable assertion formatting in `assertions.gleam`, and put
canonical input strings in `fixtures.gleam`; section-specific setup remains
beside that section's tests.

Tests adapted from test262 assert semantic results and errors. Do not port
JavaScript harness mechanics such as property descriptors, prototype identity,
coercion spies, subclass constructors, or ECMA-402 formatting. Their coverage
records remain `n/a-js-runtime` with a rationale.
