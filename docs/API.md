# Target public API

Status: design target. This document defines the intended Gleam-facing API for
future conformance batches; it is not a statement that every signature is
implemented today.

This package is a semantic port of TC39 Temporal, not a JavaScript object-model
clone. It preserves useful Temporal observables—ISO serialization, matching
field names, arithmetic and conversion operations—while using modules,
immutable values, `Result`, `Option`, labeled arguments, and
`gleam/order.Order`.

The signatures below are Gleam-looking declarations for the target contract.
Final source declarations include implementations and `///` documentation.

## Principles

- Types that carry invariants are opaque and constructed through validating
  functions.
- `Duration` remains a public labeled record and has no field-filling factory.
- Parsing, validation, range checks, missing context, time-zone ambiguity, and
  platform access return `Result`.
- `Option` means a value is absent, never that an operation failed.
- `compare` returns `gleam/order.Order`; equality predicates return `Bool`.
- Exact epoch nanoseconds use `bigi.BigInt` on both Erlang and JavaScript.
- Conversion names use `from_...` and `to_...`. Serialization names the
  representation, for example `to_iso_8601`.
- Closed option and identifier sets are custom types with variants, not
  `String`. JavaScript option strings (`"constrain"`, `"iso8601"`, `"UTC"`,
  …) are parsed at the boundary with `from_string` / `from_id` and serialized
  with `to_string` / `id`. See [JavaScript strings mapped to Gleam
  variants](#javascript-strings-mapped-to-gleam-variants).
- The ISO 8601 calendar is required. Non-ISO calendar data and IANA time-zone
  rules are provider concerns and may ship separately.

## Shared types — `temporal`

```gleam
pub type Error {
  InvalidIsoString(input: String)
  OutOfRange(field: Field, value: String)
  InvalidDuration(reason: String)
  InvalidOption(option: OptionKind)
  MissingRelativeTo
  UnknownCalendar(id: String)
  UnknownTimeZone(id: String)
  AmbiguousLocalTime
  NonexistentLocalTime
  OffsetMismatch
  PlatformUnavailable(operation: PlatformOperation)
}

pub type Field {
  Year
  Month
  Day
  Hour
  Minute
  Second
  Millisecond
  Microsecond
  Nanosecond
  Offset
  EpochMilliseconds
  EpochNanoseconds
  Date
  Time
  YearMonth
  MonthDay
  IsoDate
  EpochDays
}

pub type OptionKind {
  OverflowOption
  RoundingIncrementOption
  RoundingModeOption
  DifferenceOptions
  ToStringOptions
}

pub type PlatformOperation {
  SystemClock
  LocalTimeZoneDiscovery
  ZonedDateTimeFromIso8601
  ZonedDateTimeAdd
  ZonedDateTimeSubtract
  ZonedDateTimeStartOfDay
  ZonedDateTimeHoursInDay
  ZonedDateTimeToIso8601
}

pub type Unit {
  Year
  Month
  Week
  Day
  Hour
  Minute
  Second
  Millisecond
  Microsecond
  Nanosecond
}

pub type Overflow {
  Constrain
  Reject
}

pub type RoundingMode {
  Ceil
  Floor
  Trunc
  Expand
  HalfCeil
  HalfFloor
  HalfTrunc
  HalfExpand
  HalfEven
}

pub type Disambiguation {
  Compatible
  Earlier
  Later
  Reject
}

pub type OffsetBehavior {
  Prefer
  Use
  Ignore
  Reject
}

pub type Display {
  Auto
  Always
  Never
  Critical
}

pub type Precision {
  AutoPrecision
  Digits(Int)
}

pub type DifferenceOptions {
  DifferenceOptions(
    largest_unit: Unit,
    smallest_unit: Unit,
    rounding_increment: Int,
    rounding_mode: RoundingMode,
  )
}

pub type ToStringOptions {
  ToStringOptions(
    precision: Precision,
    smallest_unit: Option(Unit),
    rounding_mode: RoundingMode,
    calendar_name: Display,
    time_zone_name: Display,
    offset: Display,
  )
}
```

Gleam constructors share a module-level namespace. `Overflow`,
`Disambiguation`, and `OffsetBehavior` each include Temporal's `"reject"`
option. If those three types are declared together in `temporal`, only one
constructor may be named `Reject`; keep `Reject` on `Overflow` and spell the
others `RejectAmbiguous` and `RejectOffset`, or give each option type its own
module so every `"reject"` mapping can be `Reject`. Call sites still pass the
typed variant, never the JS string.

Only relevant fields are read by each operation. Module-level convenience
functions should provide sensible defaults, so callers do not have to build a
large options record for ordinary ISO output.

## `temporal/duration`

```gleam
pub type Duration {
  Duration(
    is_negative: Bool,
    years: Int,
    months: Int,
    weeks: Int,
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    milliseconds: Int,
    microseconds: Int,
    nanoseconds: Int,
  )
}

pub opaque type RelativeTo

pub fn from_iso_8601(value: String) -> Result(Duration, temporal.Error)
pub fn relative_to_from_iso_8601(
  value: String,
) -> Result(RelativeTo, temporal.Error)
pub fn validate(duration: Duration) -> Result(Duration, temporal.Error)
pub fn compare(
  first: Duration,
  second: Duration,
  relative_to: Option(RelativeTo),
) -> Result(order.Order, temporal.Error)
pub fn equal(first: Duration, second: Duration) -> Bool
pub fn add(
  first: Duration,
  second: Duration,
  relative_to: Option(RelativeTo),
) -> Result(Duration, temporal.Error)
pub fn subtract(
  first: Duration,
  second: Duration,
  relative_to: Option(RelativeTo),
) -> Result(Duration, temporal.Error)
pub fn negated(duration: Duration) -> Duration
pub fn absolute(duration: Duration) -> Duration
pub fn round(
  duration: Duration,
  smallest_unit: temporal.Unit,
  largest_unit: temporal.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
  relative_to: Option(RelativeTo),
) -> Result(Duration, temporal.Error)
pub fn total(
  duration: Duration,
  unit: temporal.Unit,
  relative_to: Option(RelativeTo),
) -> Result(Float, temporal.Error)
pub fn to_iso_8601(duration: Duration) -> String
pub fn to_iso_8601_with_options(
  duration: Duration,
  options: temporal.ToStringOptions,
) -> Result(String, temporal.Error)
```

All integer fields are non-negative magnitudes and `is_negative` is the single
sign. Zero is canonicalized to `is_negative: False`. Consumers construct
ordinary durations directly:

```gleam
let one_day =
  duration.Duration(
    is_negative: False,
    years: 0,
    months: 0,
    weeks: 0,
    days: 1,
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
    nanoseconds: 0,
  )
```

`RelativeTo` is parsed from Temporal's annotated ISO form in the first API
version. Typed convenience conversions from `PlainDate` and `ZonedDateTime`
may be added later without changing duration arithmetic.

## `temporal/instant`

```gleam
pub opaque type Instant

pub fn from_iso_8601(value: String) -> Result(Instant, temporal.Error)
pub fn from_epoch_milliseconds(
  milliseconds: Int,
) -> Result(Instant, temporal.Error)
pub fn from_epoch_nanoseconds(
  nanoseconds: bigi.BigInt,
) -> Result(Instant, temporal.Error)
pub fn epoch_milliseconds(instant: Instant) -> Int
pub fn epoch_nanoseconds(instant: Instant) -> bigi.BigInt
pub fn compare(first: Instant, second: Instant) -> order.Order
pub fn equal(first: Instant, second: Instant) -> Bool
pub fn add(
  instant: Instant,
  duration: duration.Duration,
) -> Result(Instant, temporal.Error)
pub fn subtract(
  instant: Instant,
  duration: duration.Duration,
) -> Result(Instant, temporal.Error)
pub fn until(
  first: Instant,
  second: Instant,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn since(
  first: Instant,
  second: Instant,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn round(
  instant: Instant,
  smallest_unit: temporal.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(Instant, temporal.Error)
pub fn to_iso_8601(instant: Instant) -> String
pub fn to_iso_8601_with_options(
  instant: Instant,
  options: temporal.ToStringOptions,
) -> Result(String, temporal.Error)
```

`from_epoch_nanoseconds` is the desired name for the current provisional
`from_epoch_nanoseconds_int`; its argument already identifies the `bigi`
representation. `Instant` must enforce Temporal's inclusive ±10^8-day range.

Conversions involving a time zone live in `temporal/zoned_date_time` to keep
module dependencies acyclic.

## `temporal/plain_date`

```gleam
pub opaque type PlainDate

pub fn new(
  year year: Int,
  month month: Int,
  day day: Int,
  calendar calendar: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error)
pub fn from_iso_8601(value: String) -> Result(PlainDate, temporal.Error)
pub fn from_year_month(
  year_month: plain_year_month.PlainYearMonth,
  day: Int,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error)
pub fn from_month_day(
  month_day: plain_month_day.PlainMonthDay,
  year: Int,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error)
pub fn year(date: PlainDate) -> Int
pub fn month(date: PlainDate) -> Int
pub fn month_code(date: PlainDate) -> String
pub fn day(date: PlainDate) -> Int
pub fn calendar(date: PlainDate) -> calendar.Calendar
pub fn day_of_week(date: PlainDate) -> Int
pub fn day_of_year(date: PlainDate) -> Int
pub fn week_of_year(date: PlainDate) -> Option(Int)
pub fn year_of_week(date: PlainDate) -> Option(Int)
pub fn days_in_week(date: PlainDate) -> Int
pub fn days_in_month(date: PlainDate) -> Int
pub fn days_in_year(date: PlainDate) -> Int
pub fn months_in_year(date: PlainDate) -> Int
pub fn in_leap_year(date: PlainDate) -> Bool
pub fn compare(first: PlainDate, second: PlainDate) -> order.Order
pub fn equal(first: PlainDate, second: PlainDate) -> Bool
pub fn add(
  date: PlainDate,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error)
pub fn subtract(
  date: PlainDate,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDate, temporal.Error)
pub fn until(
  first: PlainDate,
  second: PlainDate,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn since(
  first: PlainDate,
  second: PlainDate,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn to_iso_8601(date: PlainDate) -> String
pub fn to_iso_8601_with_options(
  date: PlainDate,
  options: temporal.ToStringOptions,
) -> Result(String, temporal.Error)
```

Partial-field replacement corresponding to JavaScript `with` is named
`with_fields` and is deferred until a Gleam-native partial-record type is
designed. It must not emulate JavaScript property bags with dynamic values.

## `temporal/plain_time`

```gleam
pub opaque type PlainTime

pub fn new(
  hour hour: Int,
  minute minute: Int,
  second second: Int,
  millisecond millisecond: Int,
  microsecond microsecond: Int,
  nanosecond nanosecond: Int,
  overflow overflow: temporal.Overflow,
) -> Result(PlainTime, temporal.Error)
pub fn from_iso_8601(value: String) -> Result(PlainTime, temporal.Error)
pub fn hour(time: PlainTime) -> Int
pub fn minute(time: PlainTime) -> Int
pub fn second(time: PlainTime) -> Int
pub fn millisecond(time: PlainTime) -> Int
pub fn microsecond(time: PlainTime) -> Int
pub fn nanosecond(time: PlainTime) -> Int
pub fn compare(first: PlainTime, second: PlainTime) -> order.Order
pub fn equal(first: PlainTime, second: PlainTime) -> Bool
pub fn add(
  time: PlainTime,
  duration: duration.Duration,
) -> Result(PlainTime, temporal.Error)
pub fn subtract(
  time: PlainTime,
  duration: duration.Duration,
) -> Result(PlainTime, temporal.Error)
pub fn until(
  first: PlainTime,
  second: PlainTime,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn since(
  first: PlainTime,
  second: PlainTime,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn round(
  time: PlainTime,
  smallest_unit: temporal.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(PlainTime, temporal.Error)
pub fn to_iso_8601(time: PlainTime) -> String
pub fn to_iso_8601_with_options(
  time: PlainTime,
  options: temporal.ToStringOptions,
) -> Result(String, temporal.Error)
```

## `temporal/plain_date_time`

```gleam
pub opaque type PlainDateTime

pub fn new(
  year year: Int,
  month month: Int,
  day day: Int,
  hour hour: Int,
  minute minute: Int,
  second second: Int,
  millisecond millisecond: Int,
  microsecond microsecond: Int,
  nanosecond nanosecond: Int,
  calendar calendar: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error)
pub fn from_iso_8601(value: String) -> Result(PlainDateTime, temporal.Error)
pub fn from_date_and_time(
  date: plain_date.PlainDate,
  time: plain_time.PlainTime,
) -> Result(PlainDateTime, temporal.Error)
pub fn to_plain_date(value: PlainDateTime) -> plain_date.PlainDate
pub fn to_plain_time(value: PlainDateTime) -> plain_time.PlainTime
pub fn year(value: PlainDateTime) -> Int
pub fn month(value: PlainDateTime) -> Int
pub fn month_code(value: PlainDateTime) -> String
pub fn day(value: PlainDateTime) -> Int
pub fn hour(value: PlainDateTime) -> Int
pub fn minute(value: PlainDateTime) -> Int
pub fn second(value: PlainDateTime) -> Int
pub fn millisecond(value: PlainDateTime) -> Int
pub fn microsecond(value: PlainDateTime) -> Int
pub fn nanosecond(value: PlainDateTime) -> Int
pub fn calendar(value: PlainDateTime) -> calendar.Calendar
pub fn compare(first: PlainDateTime, second: PlainDateTime) -> order.Order
pub fn equal(first: PlainDateTime, second: PlainDateTime) -> Bool
pub fn add(
  value: PlainDateTime,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error)
pub fn subtract(
  value: PlainDateTime,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainDateTime, temporal.Error)
pub fn until(
  first: PlainDateTime,
  second: PlainDateTime,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn since(
  first: PlainDateTime,
  second: PlainDateTime,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn round(
  value: PlainDateTime,
  smallest_unit: temporal.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(PlainDateTime, temporal.Error)
pub fn to_iso_8601(value: PlainDateTime) -> String
pub fn to_iso_8601_with_options(
  value: PlainDateTime,
  options: temporal.ToStringOptions,
) -> Result(String, temporal.Error)
```

Calendar-derived accessors from `PlainDate`—for example `day_of_week`,
`days_in_month`, and `in_leap_year`—also belong here with the same names.

## `temporal/plain_year_month`

```gleam
pub opaque type PlainYearMonth

pub fn new(
  year year: Int,
  month month: Int,
  reference_day reference_day: Int,
  calendar calendar: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error)
pub fn from_iso_8601(value: String) -> Result(PlainYearMonth, temporal.Error)
pub fn year(value: PlainYearMonth) -> Int
pub fn month(value: PlainYearMonth) -> Int
pub fn month_code(value: PlainYearMonth) -> String
pub fn calendar(value: PlainYearMonth) -> calendar.Calendar
pub fn days_in_month(value: PlainYearMonth) -> Int
pub fn days_in_year(value: PlainYearMonth) -> Int
pub fn months_in_year(value: PlainYearMonth) -> Int
pub fn in_leap_year(value: PlainYearMonth) -> Bool
pub fn compare(first: PlainYearMonth, second: PlainYearMonth) -> order.Order
pub fn equal(first: PlainYearMonth, second: PlainYearMonth) -> Bool
pub fn add(
  value: PlainYearMonth,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error)
pub fn subtract(
  value: PlainYearMonth,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(PlainYearMonth, temporal.Error)
pub fn until(
  first: PlainYearMonth,
  second: PlainYearMonth,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn since(
  first: PlainYearMonth,
  second: PlainYearMonth,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn to_iso_8601(value: PlainYearMonth) -> String
```

## `temporal/plain_month_day`

```gleam
pub opaque type PlainMonthDay

pub fn new(
  month month: Int,
  day day: Int,
  reference_year reference_year: Int,
  calendar calendar: calendar.Calendar,
  overflow overflow: temporal.Overflow,
) -> Result(PlainMonthDay, temporal.Error)
pub fn from_iso_8601(value: String) -> Result(PlainMonthDay, temporal.Error)
pub fn month_code(value: PlainMonthDay) -> String
pub fn day(value: PlainMonthDay) -> Int
pub fn calendar(value: PlainMonthDay) -> calendar.Calendar
pub fn equal(first: PlainMonthDay, second: PlainMonthDay) -> Bool
pub fn to_iso_8601(value: PlainMonthDay) -> String
```

Temporal does not define ordering or duration arithmetic for
`PlainMonthDay`; this module intentionally omits it.

## `temporal/calendar`

```gleam
pub type Calendar {
  Iso8601
}

pub fn iso_8601() -> Calendar
pub fn from_string(id: String) -> Result(Calendar, temporal.Error)
pub fn from_id(id: String) -> Result(Calendar, temporal.Error)
pub fn to_string(calendar: Calendar) -> String
pub fn id(calendar: Calendar) -> String
pub fn equal(first: Calendar, second: Calendar) -> Bool
```

`Calendar` is a closed variant type, not `Calendar(id: String)`. The first
implementation provides only `Iso8601`. `from_string` / `from_id` parse the
spec identifier (`"iso8601"`, case-insensitive) at the boundary;
`to_string` / `id` emit the canonical spec string for serialization. In-process
APIs take and return `Calendar`, never the identifier string.

Calendar-specific field access and arithmetic remain operations on the Plain
types rather than a JavaScript-style calendar protocol object.

Additional built-in calendars require a data source and conformance plan.
User-defined JavaScript calendar protocol objects, method interception, and
ECMA-402-only calendar behavior are out of scope.

## `temporal/time_zone`

```gleam
pub type TimeZone {
  Utc
  FixedOffset(total_minutes: Int)
}

pub fn utc() -> TimeZone
pub fn from_string(id: String) -> Result(TimeZone, temporal.Error)
pub fn from_id(id: String) -> Result(TimeZone, temporal.Error)
pub fn from_offset(offset: String) -> Result(TimeZone, temporal.Error)
pub fn to_string(time_zone: TimeZone) -> String
pub fn id(time_zone: TimeZone) -> String
pub fn equal(first: TimeZone, second: TimeZone) -> Bool
pub fn offset_nanoseconds_for(
  time_zone: TimeZone,
  instant: instant.Instant,
) -> Result(Int, temporal.Error)
pub fn offset_iso_8601_for(
  time_zone: TimeZone,
  instant: instant.Instant,
) -> Result(String, temporal.Error)
```

Time-zone *kind* is a variant type, not `TimeZone(id: String)`. UTC is `Utc`.
Fixed offsets are `FixedOffset` with a validated minute count; `from_offset`
parses `+HH:MM` / `-HH:MM` at the boundary. Named IANA zones are not a closed
core set: they require an explicit, versioned provider and must not be a
freely constructed string field. The core API must not delegate silently to
host-local rules because that would make Erlang and JavaScript results differ.

Custom JavaScript time-zone protocol objects and method interception are out
of scope.

## `temporal/zoned_date_time`

```gleam
pub opaque type ZonedDateTime

pub fn from_iso_8601(value: String) -> Result(ZonedDateTime, temporal.Error)
pub fn from_instant(
  instant: instant.Instant,
  time_zone: time_zone.TimeZone,
  calendar: calendar.Calendar,
) -> Result(ZonedDateTime, temporal.Error)
pub fn from_plain_date_time(
  date_time: plain_date_time.PlainDateTime,
  time_zone: time_zone.TimeZone,
  disambiguation: temporal.Disambiguation,
) -> Result(ZonedDateTime, temporal.Error)
pub fn to_instant(value: ZonedDateTime) -> instant.Instant
pub fn to_plain_date_time(
  value: ZonedDateTime,
) -> Result(plain_date_time.PlainDateTime, temporal.Error)
pub fn epoch_milliseconds(value: ZonedDateTime) -> Int
pub fn epoch_nanoseconds(value: ZonedDateTime) -> bigi.BigInt
pub fn time_zone(value: ZonedDateTime) -> time_zone.TimeZone
pub fn calendar(value: ZonedDateTime) -> calendar.Calendar
pub fn offset_nanoseconds(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn offset(value: ZonedDateTime) -> Result(String, temporal.Error)
pub fn year(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn month(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn month_code(value: ZonedDateTime) -> Result(String, temporal.Error)
pub fn day(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn hour(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn minute(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn second(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn millisecond(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn microsecond(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn nanosecond(value: ZonedDateTime) -> Result(Int, temporal.Error)
pub fn compare(first: ZonedDateTime, second: ZonedDateTime) -> order.Order
pub fn equal(first: ZonedDateTime, second: ZonedDateTime) -> Bool
pub fn add(
  value: ZonedDateTime,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(ZonedDateTime, temporal.Error)
pub fn subtract(
  value: ZonedDateTime,
  duration: duration.Duration,
  overflow: temporal.Overflow,
) -> Result(ZonedDateTime, temporal.Error)
pub fn until(
  first: ZonedDateTime,
  second: ZonedDateTime,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn since(
  first: ZonedDateTime,
  second: ZonedDateTime,
  options: temporal.DifferenceOptions,
) -> Result(duration.Duration, temporal.Error)
pub fn round(
  value: ZonedDateTime,
  smallest_unit: temporal.Unit,
  rounding_increment: Int,
  rounding_mode: temporal.RoundingMode,
) -> Result(ZonedDateTime, temporal.Error)
pub fn start_of_day(value: ZonedDateTime) -> Result(ZonedDateTime, temporal.Error)
pub fn hours_in_day(value: ZonedDateTime) -> Result(Float, temporal.Error)
pub fn to_iso_8601(value: ZonedDateTime) -> Result(String, temporal.Error)
pub fn to_iso_8601_with_options(
  value: ZonedDateTime,
  options: temporal.ToStringOptions,
) -> Result(String, temporal.Error)
```

Other calendar-derived date accessors mirror `PlainDate`. They return `Result`
because resolving the local representation can require provider data.

## `temporal/now`

```gleam
pub opaque type Clock

pub fn system_clock() -> Clock
pub fn fixed_clock(
  instant: instant.Instant,
  time_zone: time_zone.TimeZone,
) -> Clock
pub fn instant() -> Result(instant.Instant, temporal.Error)
pub fn instant_with_clock(
  clock: Clock,
) -> Result(instant.Instant, temporal.Error)
pub fn time_zone() -> Result(time_zone.TimeZone, temporal.Error)
pub fn time_zone_with_clock(
  clock: Clock,
) -> Result(time_zone.TimeZone, temporal.Error)
pub fn zoned_date_time_iso(
  time_zone: Option(time_zone.TimeZone),
) -> Result(zoned_date_time.ZonedDateTime, temporal.Error)
pub fn plain_date_time_iso(
  time_zone: Option(time_zone.TimeZone),
) -> Result(plain_date_time.PlainDateTime, temporal.Error)
pub fn plain_date_iso(
  time_zone: Option(time_zone.TimeZone),
) -> Result(plain_date.PlainDate, temporal.Error)
pub fn plain_time_iso(
  time_zone: Option(time_zone.TimeZone),
) -> Result(plain_time.PlainTime, temporal.Error)
```

`fixed_clock` makes tests deterministic without replacing global state.
System-clock and local-zone discovery use small target-specific adapters for
Erlang and JavaScript; all subsequent conversion remains target-neutral.

## JavaScript names mapped to Gleam

- `Temporal.X.from(string)` → `x.from_iso_8601(string)`.
- `Temporal.Instant.fromEpochMilliseconds` →
  `instant.from_epoch_milliseconds`.
- `Temporal.Instant.fromEpochNanoseconds` →
  `instant.from_epoch_nanoseconds`.
- Property getters such as `epochNanoseconds` → `epoch_nanoseconds`.
- `calendarId` / `timeZoneId` → `calendar(...)` / `time_zone(...)`, returning
  `calendar.Calendar` / `time_zone.TimeZone`, not strings.
- Prototype methods → module functions with the value first:
  `date.add(duration)` → `plain_date.add(date, duration, ...)`.
- `toString` → `to_iso_8601`; configurable output uses
  `to_iso_8601_with_options`.
- `equals` → `equal`.
- Static `compare` → module `compare`, returning `Order` rather than `-1`,
  `0`, or `1`.
- JavaScript `with` → eventual `with_fields`; `with` is not used as the public
  function name.
- JavaScript property bags → labeled constructors, typed options, or explicit
  partial-field records; never dynamic maps.
- Throwing `RangeError` or `TypeError` → `Error(temporal.Error)`.
- Omitted/`undefined` arguments → explicit defaults or `Option`.

## JavaScript strings mapped to Gleam variants

Pass these as variants in Gleam. Convert the JS/spec string only at a
`from_string` (or `from_id` / `from_offset`) boundary.

Calendar (`calendar.Calendar`):

- `"iso8601"` → `Iso8601`

Time zone (`time_zone.TimeZone`):

- `"UTC"` → `Utc`
- `"+HH:MM"` / `"-HH:MM"` → `FixedOffset(total_minutes)` (parsed by
  `from_offset`)

Overflow (`temporal.Overflow`):

- `"constrain"` → `Constrain`
- `"reject"` → `Reject`

Disambiguation (`temporal.Disambiguation`):

- `"compatible"` → `Compatible`
- `"earlier"` → `Earlier`
- `"later"` → `Later`
- `"reject"` → `Reject`

Offset option (`temporal.OffsetBehavior`):

- `"prefer"` → `Prefer`
- `"use"` → `Use`
- `"ignore"` → `Ignore`
- `"reject"` → `Reject`

Rounding mode (`temporal.RoundingMode`):

- `"ceil"` → `Ceil`
- `"floor"` → `Floor`
- `"trunc"` → `Trunc`
- `"expand"` → `Expand`
- `"halfCeil"` → `HalfCeil`
- `"halfFloor"` → `HalfFloor`
- `"halfTrunc"` → `HalfTrunc`
- `"halfExpand"` → `HalfExpand`
- `"halfEven"` → `HalfEven`

Unit (`temporal.Unit`):

- `"year"` → `Year`
- `"month"` → `Month`
- `"week"` → `Week`
- `"day"` → `Day`
- `"hour"` → `Hour`
- `"minute"` → `Minute`
- `"second"` → `Second`
- `"millisecond"` → `Millisecond`
- `"microsecond"` → `Microsecond`
- `"nanosecond"` → `Nanosecond`

Display (`temporal.Display`), for `ToStringOptions` annotation flags:

- `"auto"` → `Auto`
- `"always"` → `Always`
- `"never"` → `Never`
- `"critical"` → `Critical`


## Deliberately deferred or out of scope

Deferred until their data model is designed:

- Typed partial-field records and `with_fields` for Plain and Zoned types.
- Named IANA zones beyond UTC/fixed offsets, including a versioned provider.
- Non-ISO built-in calendars and locale-derived calendar behavior.
- Locale formatting (`toLocaleString`) and all other ECMA-402-only behavior.
- Interop adapters to and from the separate `gleam_time` package.
- A stable serialization format other than Temporal ISO strings.

Out of scope:

- JavaScript prototypes, constructors as objects, property descriptors,
  symbols, subclassing, coercion hooks, observable property access order, and
  custom protocol objects.
- Legacy JavaScript `Date`.
- Reproducing host exceptions or JavaScript `undefined`.

The `conformance/` inventory remains authoritative for whether each pinned
Temporal clause is direct, indirect, or `n/a-js-runtime`.

## Research basis

- [Gleam language tour](https://tour.gleam.run/everything/) — labeled
  arguments, records and updates, opaque types, documentation comments,
  `Result`, and multi-target externals.
- [Gleam conventions, patterns, and
  anti-patterns](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/)
  — naming, singular modules, annotations, conversion names, and fallible
  functions.
- [`gleam/result`](https://hexdocs.pm/gleam_stdlib/gleam/result.html),
  [`gleam/option`](https://hexdocs.pm/gleam_stdlib/gleam/option.html),
  [`gleam/order`](https://hexdocs.pm/gleam_stdlib/gleam/order.html),
  [`gleam/int`](https://hexdocs.pm/gleam_stdlib/gleam/int.html), and
  [`gleam/string`](https://hexdocs.pm/gleam_stdlib/gleam/string.html).
- [`bigi`](https://hexdocs.pm/bigi/3.2.0/) — cross-target arbitrary-precision
  integer representation.
- [`gleam_time`](https://gleam-time.hexdocs.pm/) — the separate official Gleam
  time package and the boundary between epoch timestamps and calendar values.
- [TC39 Temporal proposal](https://tc39.es/proposal-temporal/) and
  [Temporal documentation](https://tc39.es/proposal-temporal/docs/).
- This repository's immutable Temporal and test262 pins in
  [`conformance/sources.json`](../conformance/sources.json).
