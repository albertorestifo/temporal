# Temporal conformance inventory

This directory tracks the semantic Gleam port against immutable Temporal
proposal, proposal-documentation, and test262 revisions. `sources.json` is the
source of truth for those revisions and their retained license notices.

## Coverage records

`coverage/01-*.json` through `coverage/15-*.json` correspond one-for-one with
official specification sections 1 through 15. Each specification clause has a
stable requirement ID and these fields:

- `spec_anchor` and `spec_url`: the normative clause and its immutable source.
- `disposition`: `direct`, `indirect`, or `n/a-js-runtime`.
- `coverage_status`: `planned`, `active`, `complete`, or `exempt`.
- `gleam_test_ids`: independently named Gleam tests that cover the clause, in
  stable `module/path::function_test` form.
- `test262_paths`: pinned upstream observable cases for the clause.
- `official_example_links`: pinned proposal documentation or cookbook links.
- `rationale`: mandatory for `n/a-js-runtime`, otherwise `null`.

`planned` is the inventory state used before a section batch starts, so its
test list may be empty. A batch changes an applicable record to `active` when
it introduces the RED test and to `complete` once the implementation passes.
The checker rejects `active` or `complete` applicable records without tests.

JavaScript prototypes, descriptors, symbols, coercion hooks, subclassing,
legacy `Date`, and ECMA-402-only behavior stay visible as `n/a-js-runtime`
records. They must never be removed simply because the Gleam runtime does not
implement the JavaScript object model.

## Commands

Validate the checked-in inventory without network access:

```sh
python3 scripts/check_conformance.py
```

Regenerate the clause and test262 mapping from the immutable pins (network
access required):

```sh
python3 scripts/build_conformance_inventory.py
python3 scripts/check_conformance.py
```

The generator groups test262 files by their `esid` metadata, falling back to
the standard `test/built-ins/Temporal/<type>/<operation>` path convention.
`test262-manifest.json` records the pinned corpus size and makes an unmapped
upstream file a validation failure.
