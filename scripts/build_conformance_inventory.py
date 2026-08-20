#!/usr/bin/env python3
"""Regenerate the Temporal conformance inventory from immutable upstream pins."""

from __future__ import annotations

import html
import io
import json
import re
import tarfile
import urllib.request
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCES = json.loads((ROOT / "conformance" / "sources.json").read_text())
PROPOSAL_SHA = SOURCES["sources"]["temporal_spec"]["commit"]
TEST262_SHA = SOURCES["sources"]["test262"]["commit"]
PROPOSAL_RAW = (
    f"https://raw.githubusercontent.com/tc39/proposal-temporal/{PROPOSAL_SHA}/"
)
PROPOSAL_BLOB = (
    f"https://github.com/tc39/proposal-temporal/blob/{PROPOSAL_SHA}/"
)
TEST262_TREE = f"https://github.com/tc39/test262/blob/{TEST262_SHA}/"

SECTIONS = {
    1: ("namespace", "Temporal namespace", "spec/temporal.html"),
    2: ("now", "Temporal.Now", "spec/temporal.html"),
    3: ("plain-date", "Temporal.PlainDate", "spec/plaindate.html"),
    4: ("plain-time", "Temporal.PlainTime", "spec/plaintime.html"),
    5: ("plain-date-time", "Temporal.PlainDateTime", "spec/plaindatetime.html"),
    6: ("zoned-date-time", "Temporal.ZonedDateTime", "spec/zoneddatetime.html"),
    7: ("duration", "Temporal.Duration", "spec/duration.html"),
    8: ("instant", "Temporal.Instant", "spec/instant.html"),
    9: ("plain-year-month", "Temporal.PlainYearMonth", "spec/plainyearmonth.html"),
    10: ("plain-month-day", "Temporal.PlainMonthDay", "spec/plainmonthday.html"),
    11: ("time-zones", "Time zones", "spec/timezone.html"),
    12: ("calendars", "Calendars", "spec/calendar.html"),
    13: ("abstract-operations", "Temporal abstract operations", "spec/abstractops.html"),
    14: ("ecma-262-amendments", "ECMA-262 amendments", "spec/mainadditions.html"),
    15: ("ecma-402-amendments", "ECMA-402 amendments", "spec/intl.html"),
}

SECTION_ROOTS = {
    1: "sec-temporal-objects",
    2: "sec-temporal-now-object",
    3: "sec-temporal-plaindate-objects",
    4: "sec-temporal-plaintime-objects",
    5: "sec-temporal-plaindatetime-objects",
    6: "sec-temporal-zoneddatetime-objects",
    7: "sec-temporal-duration-objects",
    8: "sec-temporal-instant-objects",
    9: "sec-temporal-plainyearmonth-objects",
    10: "sec-temporal-plainmonthday-objects",
    11: "sec-temporal-timezones",
    12: "sec-temporal-calendars",
    13: "sec-temporal-abstract-ops",
    14: "sec-temporal-legacy-date-objects",
    15: "sec-temporal-intl",
}

DOC_LINKS = {
    2: "docs/cookbook.md#current-date-and-time",
    3: "docs/cookbook.md#how-many-days-until-a-future-date",
    4: "docs/cookbook.md#round-a-time-down-to-whole-hours",
    5: "docs/cookbook.md#noon-on-a-particular-date",
    6: "docs/cookbook.md#preserving-exact-time",
    7: "docs/cookbook.md#unit-constrained-duration-between-now-and-a-pastfuture-zoned-event",
    8: "docs/cookbook.md#unix-timestamp",
    9: "docs/cookbook.md#birthday-in-2030",
    10: "docs/cookbook.md#birthday-in-2030",
    11: "docs/cookbook.md#preserving-local-time",
    12: "docs/cookbook-nepali-calendar.md",
}

STRUCTURAL_OR_JS_ONLY = re.compile(
    r"(?:"
    r"%symbol|@@|tostringtag|prototype\.constructor|"
    r"\.prototype$|\.valueof$|"
    r"properties-of-|value-properties|constructor-properties|"
    r"ordinary-object|ordinarycreatefromconstructor|"
    r"getprototypefromconstructor|species|subclass|descriptor|"
    r"toprimitive"
    r")",
    re.IGNORECASE,
)


def fetch(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": "temporal-inventory"})
    with urllib.request.urlopen(request) as response:
        return response.read()


def clean_heading(fragment: str, anchor: str) -> str:
    heading = re.search(r"<h[1-6][^>]*>(.*?)</h[1-6]>", fragment, re.I | re.S)
    if not heading:
        return anchor.removeprefix("sec-").replace("-", " ")
    text = re.sub(r"<[^>]+>", "", heading.group(1))
    return " ".join(html.unescape(text).split())


def parse_clauses(source_file: str) -> list[dict[str, object]]:
    text = fetch(PROPOSAL_RAW + source_file).decode()
    token_pattern = re.compile(r"<emu-clause\b([^>]*)>|</emu-clause>", re.I)
    tokens = list(token_pattern.finditer(text))
    stack: list[str] = []
    clauses: list[dict[str, object]] = []

    for index, token in enumerate(tokens):
        if token.group(1) is None:
            if stack:
                stack.pop()
            continue
        attributes = token.group(1)
        id_match = re.search(r"\bid=[\"']([^\"']+)", attributes, re.I)
        if not id_match:
            stack.append("")
            continue
        anchor = id_match.group(1)
        next_start = tokens[index + 1].start() if index + 1 < len(tokens) else len(text)
        clauses.append(
            {
                "anchor": anchor,
                "summary": clean_heading(text[token.end() : next_start], anchor),
                "parents": [parent for parent in stack if parent],
                "source_file": source_file,
            }
        )
        stack.append(anchor)
    return clauses


def section_for_clause(
    source_file: str, anchor: str, parents: list[str]
) -> int:
    if source_file == "spec/temporal.html":
        now_clauses = [anchor, *parents]
        return 2 if "sec-temporal-now-object" in now_clauses else 1
    for number, (_, _, candidate) in SECTIONS.items():
        if candidate == source_file:
            return number
    raise ValueError(f"No section mapping for {source_file}")


def disposition(section: int, anchor: str, parents: list[str]) -> tuple[str, str | None]:
    ancestry = " ".join([anchor, *parents])
    if section == 15:
        return (
            "n/a-js-runtime",
            "ECMA-402 internationalization objects and formatting behavior are outside the Gleam semantic-port runtime contract.",
        )
    if section == 14:
        return (
            "n/a-js-runtime",
            "This ECMA-262 amendment concerns legacy Date, JavaScript language semantics, intrinsics, coercion, or object-model integration outside the Gleam runtime contract.",
        )
    if section == 1:
        return (
            "n/a-js-runtime",
            "JavaScript namespace object properties, descriptors, prototypes, and constructor exposure are represented by Gleam modules and are outside the semantic-port contract.",
        )
    if STRUCTURAL_OR_JS_ONLY.search(anchor):
        return (
            "n/a-js-runtime",
            "JavaScript prototype, property-descriptor, coercion, symbol, subclassing, or intrinsic-object behavior is outside the Gleam semantic-port contract.",
        )
    if section == 13 or "abstract-op" in ancestry or "abstract operation" in ancestry:
        return (
            "indirect",
            None,
        )
    if anchor.startswith("sec-temporal."):
        return ("direct", None)
    return ("indirect", None)


def normalize_anchor(value: str) -> str:
    return value.casefold()


def inferred_anchor(path: str) -> str | None:
    marker = "test/built-ins/Temporal/"
    if marker not in path:
        return None
    parts = path.split(marker, 1)[1].split("/")
    if len(parts) < 2:
        return None
    owner = parts[0].casefold()
    if owner == "now":
        return f"sec-temporal.now.{parts[1].removesuffix('.js').casefold()}"
    if len(parts) >= 3 and parts[1] == "prototype":
        return f"sec-temporal.{owner}.prototype.{parts[2].removesuffix('.js').casefold()}"
    operation = parts[1].removesuffix(".js").casefold()
    if operation == "constructor":
        return f"sec-temporal.{owner}"
    return f"sec-temporal.{owner}.{operation}"


def load_test262_paths() -> tuple[list[tuple[str | None, str | None, str]], list[str]]:
    archive_url = f"https://codeload.github.com/tc39/test262/tar.gz/{TEST262_SHA}"
    entries: list[tuple[str | None, str | None, str]] = []
    all_paths: list[str] = []
    with tarfile.open(fileobj=io.BytesIO(fetch(archive_url)), mode="r:gz") as archive:
        for member in archive:
            marker = "/test/built-ins/Temporal/"
            if not member.isfile() or marker not in member.name or not member.name.endswith(".js"):
                continue
            path = "test/" + member.name.split("/test/", 1)[1]
            all_paths.append(path)
            content_file = archive.extractfile(member)
            content = content_file.read().decode(errors="replace") if content_file else ""
            frontmatter = re.search(r"/\*---(.*?)---\*/", content, re.S)
            esid = None
            if frontmatter:
                match = re.search(r"^esid:\s*['\"]?([^'\"\s]+)", frontmatter.group(1), re.M)
                if match and match.group(1).startswith("sec-"):
                    esid = match.group(1)
            entries.append((esid, inferred_anchor(path), path))
    return entries, sorted(all_paths)


def fallback_anchor(path: str) -> str:
    marker = "test/built-ins/Temporal/"
    parts = path.split(marker, 1)[1].split("/")
    owner = parts[0]
    if owner == "Now":
        return SECTION_ROOTS[2]
    owner_sections = {
        "PlainDate": 3,
        "PlainTime": 4,
        "PlainDateTime": 5,
        "ZonedDateTime": 6,
        "Duration": 7,
        "Instant": 8,
        "PlainYearMonth": 9,
        "PlainMonthDay": 10,
        "TimeZone": 11,
        "Calendar": 12,
    }
    return SECTION_ROOTS.get(owner_sections.get(owner, 1), SECTION_ROOTS[1])


def requirement_id(section: int, anchor: str) -> str:
    slug = re.sub(r"[^A-Z0-9]+", "-", anchor.upper()).strip("-")
    return f"TEMP-S{section:02d}-{slug}"


def main() -> None:
    all_clauses: list[dict[str, object]] = []
    fetched_files: set[str] = set()
    for _, _, source_file in SECTIONS.values():
        if source_file not in fetched_files:
            all_clauses.extend(parse_clauses(source_file))
            fetched_files.add(source_file)

    clauses_by_section: dict[int, list[dict[str, object]]] = defaultdict(list)
    for clause in all_clauses:
        section = section_for_clause(
            str(clause["source_file"]),
            str(clause["anchor"]),
            list(clause["parents"]),
        )
        clauses_by_section[section].append(clause)

    test262_entries, all_test262_paths = load_test262_paths()
    known_anchors = {
        normalize_anchor(str(clause["anchor"])): clause for clause in all_clauses
    }
    test262_by_anchor: dict[str, list[str]] = defaultdict(list)
    fallback_test262: list[str] = []
    for esid, inferred, path in test262_entries:
        candidates = [candidate for candidate in (esid, inferred) if candidate]
        target = next(
            (
                normalize_anchor(candidate)
                for candidate in candidates
                if normalize_anchor(candidate) in known_anchors
            ),
            normalize_anchor(fallback_anchor(path)),
        )
        if not any(normalize_anchor(candidate) in known_anchors for candidate in candidates):
            fallback_test262.append(path)
        test262_by_anchor[target].append(path)

    output_dir = ROOT / "conformance" / "coverage"
    output_dir.mkdir(parents=True, exist_ok=True)
    for section, (slug, title, source_file) in SECTIONS.items():
        requirements = []
        for clause in clauses_by_section[section]:
            anchor = str(clause["anchor"])
            parents = list(clause["parents"])
            kind, rationale = disposition(section, anchor, parents)
            requirements.append(
                {
                    "id": requirement_id(section, anchor),
                    "spec_anchor": anchor,
                    "spec_url": f"{PROPOSAL_BLOB}{source_file}#{anchor}",
                    "summary": clause["summary"],
                    "disposition": kind,
                    "coverage_status": "exempt" if kind == "n/a-js-runtime" else "planned",
                    "gleam_test_ids": [],
                    "test262_paths": test262_by_anchor.get(normalize_anchor(anchor), []),
                    "official_example_links": (
                        [f"{PROPOSAL_BLOB}{DOC_LINKS[section]}"]
                        if section in DOC_LINKS and kind != "n/a-js-runtime"
                        else []
                    ),
                    "rationale": rationale,
                }
            )

        root_anchor = SECTION_ROOTS[section]
        payload = {
            "schema_version": 1,
            "section": section,
            "section_slug": slug,
            "title": title,
            "source_file": source_file,
            "section_anchor": root_anchor,
            "section_url": f"{PROPOSAL_BLOB}{source_file}#{root_anchor}",
            "requirements": requirements,
        }
        path = output_dir / f"{section:02d}-{slug}.json"
        path.write_text(json.dumps(payload, indent=2, sort_keys=False) + "\n")

    manifest = {
        "schema_version": 1,
        "source_commit": TEST262_SHA,
        "path_count": len(all_test262_paths),
        "fallback_path_count": len(fallback_test262),
        "fallback_paths": sorted(fallback_test262),
        "unmatched_path_count": 0,
        "unmatched_paths": [],
        "source_url": SOURCES["sources"]["test262"]["source_url"],
    }
    (ROOT / "conformance" / "test262-manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n"
    )


if __name__ == "__main__":
    main()
