#!/usr/bin/env python3
"""Audit Temporal conformance traceability against immutable upstream pins."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

import build_conformance_inventory as inventory


ROOT = Path(__file__).resolve().parents[1]
COVERAGE = ROOT / "conformance" / "coverage"
TEST_ROOT = ROOT / "test"
PLACEHOLDER = re.compile(r"\b(?:todo|tbd|placeholder|fill\s+me)\b", re.I)
TEST_FUNCTION = re.compile(r"^pub fn ([a-z][a-z0-9_]*_test)\s*\(", re.M)
REQUIREMENT_COMMENT = re.compile(r"^// Requirement: (\S+)\s*$", re.M)
SPEC_COMMENT = re.compile(r"^// Spec: (\S+)\s*$", re.M)


def load_coverage() -> list[tuple[Path, dict]]:
    return [
        (path, json.loads(path.read_text()))
        for path in sorted(COVERAGE.glob("*.json"))
    ]


def load_tests() -> tuple[dict[str, str], dict[str, tuple[str | None, str | None]]]:
    sources: dict[str, str] = {}
    provenance: dict[str, tuple[str | None, str | None]] = {}
    for path in sorted(TEST_ROOT.rglob("*_test.gleam")):
        relative = path.relative_to(TEST_ROOT).with_suffix("").as_posix()
        source = path.read_text()
        sources[relative] = source
        matches = list(TEST_FUNCTION.finditer(source))
        for index, match in enumerate(matches):
            start = matches[index - 1].end() if index else 0
            prefix = source[start : match.start()]
            requirement_matches = list(REQUIREMENT_COMMENT.finditer(prefix))
            spec_matches = list(SPEC_COMMENT.finditer(prefix))
            provenance[f"{relative}::{match.group(1)}"] = (
                requirement_matches[-1].group(1) if requirement_matches else None,
                spec_matches[-1].group(1) if spec_matches else None,
            )
    return sources, provenance


def upstream_clauses() -> dict[int, dict[str, dict]]:
    clauses_by_section: dict[int, dict[str, dict]] = defaultdict(dict)
    fetched_files: set[str] = set()
    for _, _, source_file in inventory.SECTIONS.values():
        if source_file in fetched_files:
            continue
        for clause in inventory.parse_clauses(source_file):
            section = inventory.section_for_clause(
                source_file,
                str(clause["anchor"]),
                list(clause["parents"]),
            )
            clauses_by_section[section][str(clause["anchor"])] = clause
        fetched_files.add(source_file)
    return clauses_by_section


def resolve_fallback(
    path: str,
    esid: str | None,
    inferred: str | None,
    known_anchors: set[str],
) -> str | None:
    if path in {
        "test/built-ins/Temporal/Now/builtin.js",
        "test/built-ins/Temporal/Now/prop-desc.js",
    }:
        return "sec-value-properties-of-the-temporal-now-object"
    if path.startswith("test/built-ins/Temporal/Now/toStringTag/"):
        return "sec-temporal-now-%symbol.tostringtag%"

    candidates: list[str] = []
    for candidate in (esid, inferred):
        if candidate is None:
            continue
        candidates.extend(
            [
                candidate,
                candidate.replace("-@@tostringtag", "-%symbol.tostringtag%"),
                candidate.replace(".prototype.tostringtag", ".prototype-%symbol.tostringtag%"),
                candidate.removesuffix(".constructor"),
            ]
        )
        if ".prototype." in candidate:
            candidates.append(candidate.replace("sec-temporal.", "sec-get-temporal.", 1))
    if path in {
        "test/built-ins/Temporal/toStringTag/prop-desc.js",
        "test/built-ins/Temporal/toStringTag/string.js",
    }:
        candidates.append("sec-temporal-%symbol.tostringtag%")

    matches = [candidate for candidate in candidates if candidate in known_anchors]
    return matches[0] if matches else None


def fix_fallbacks(
    coverage: list[tuple[Path, dict]],
    manifest: dict,
    test262_entries: list[tuple[str | None, str | None, str]],
    clauses_by_section: dict[int, dict[str, dict]],
) -> None:
    known_anchors = {
        anchor for clauses in clauses_by_section.values() for anchor in clauses
    }
    entry_by_path = {path: (esid, inferred) for esid, inferred, path in test262_entries}
    fallback_paths = manifest.get("fallback_paths", [])
    resolutions: dict[str, str] = {}
    requirements_by_anchor: dict[str, dict] = {}
    for _, payload in coverage:
        for requirement in payload["requirements"]:
            requirements_by_anchor[requirement["spec_anchor"]] = requirement

    for path in fallback_paths:
        esid, inferred = entry_by_path[path]
        target = resolve_fallback(path, esid, inferred, known_anchors)
        if target is None:
            raise ValueError(f"Cannot resolve fallback mapping for {path}")
        for requirement in requirements_by_anchor.values():
            if path in requirement["test262_paths"]:
                requirement["test262_paths"].remove(path)
        requirements_by_anchor[target]["test262_paths"].append(path)
        requirements_by_anchor[target]["test262_paths"].sort()
        resolutions[path] = target

    for path, payload in coverage:
        path.write_text(json.dumps(payload, indent=2) + "\n")
    manifest["fallback_path_count"] = 0
    manifest["fallback_paths"] = []
    manifest["resolved_fallback_path_count"] = len(resolutions)
    manifest["resolved_fallback_paths"] = resolutions
    (ROOT / "conformance" / "test262-manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--fix-fallbacks",
        action="store_true",
        help="replace section-level test262 fallbacks with exact clause mappings",
    )
    arguments = parser.parse_args()
    coverage = load_coverage()
    _, test_provenance = load_tests()
    clauses_by_section = upstream_clauses()
    manifest = json.loads(
        (ROOT / "conformance" / "test262-manifest.json").read_text()
    )
    test262_entries, upstream_test262_paths = inventory.load_test262_paths()
    if arguments.fix_fallbacks:
        fix_fallbacks(coverage, manifest, test262_entries, clauses_by_section)
        coverage = load_coverage()
        manifest = json.loads(
            (ROOT / "conformance" / "test262-manifest.json").read_text()
        )

    errors: list[str] = []
    warnings: list[str] = []
    counts: dict[int, Counter] = defaultdict(Counter)
    statuses: Counter = Counter()
    mapped_test262: set[str] = set()
    requirement_ids: set[str] = set()
    test_ids: set[str] = set()
    example_links: set[str] = set()

    for path, payload in coverage:
        section = payload["section"]
        inventory_anchors = {
            requirement["spec_anchor"] for requirement in payload["requirements"]
        }
        upstream_anchors = set(clauses_by_section[section])
        for anchor in sorted(upstream_anchors - inventory_anchors):
            errors.append(f"missing requirement: section {section}: {anchor}")
        for anchor in sorted(inventory_anchors - upstream_anchors):
            errors.append(f"unresolved anchor: {path.name}: {anchor}")

        for requirement in payload["requirements"]:
            requirement_id = requirement["id"]
            requirement_ids.add(requirement_id)
            counts[section][requirement["disposition"]] += 1
            statuses[requirement["coverage_status"]] += 1
            mapped_test262.update(requirement["test262_paths"])
            example_links.update(requirement["official_example_links"])
            rationale = requirement["rationale"]
            if isinstance(rationale, str) and PLACEHOLDER.search(rationale):
                errors.append(f"placeholder rationale: {requirement_id}")

            for test_id in requirement["gleam_test_ids"]:
                test_ids.add(test_id)
                actual = test_provenance.get(test_id)
                if actual is None:
                    errors.append(f"missing Gleam test: {requirement_id}: {test_id}")
                    continue
                actual_requirement, actual_spec = actual
                if actual_requirement != requirement_id:
                    errors.append(
                        "wrong requirement provenance: "
                        f"{test_id}: expected {requirement_id}, got {actual_requirement}"
                    )
                if actual_spec != requirement["spec_url"]:
                    errors.append(
                        f"wrong spec provenance: {test_id}: "
                        f"expected {requirement['spec_url']}, got {actual_spec}"
                    )

    upstream_path_set = set(upstream_test262_paths)
    for path in sorted(upstream_path_set - mapped_test262):
        errors.append(f"unmapped test262 file: {path}")
    for path in sorted(mapped_test262 - upstream_path_set):
        errors.append(f"unknown test262 file: {path}")
    if len(mapped_test262) != len(upstream_test262_paths):
        errors.append(
            f"test262 cardinality mismatch: {len(mapped_test262)} mapped, "
            f"{len(upstream_test262_paths)} upstream"
        )

    fallback_paths = set(manifest.get("fallback_paths", []))
    entry_by_path = {path: (esid, inferred) for esid, inferred, path in test262_entries}
    for path in sorted(fallback_paths):
        esid, inferred = entry_by_path[path]
        warnings.append(
            f"fallback: {path} (esid={esid!r}, inferred={inferred!r}, "
            f"mapped={inventory.fallback_anchor(path)!r})"
        )

    print("Coverage by section:")
    totals: Counter = Counter()
    for path, payload in coverage:
        section = payload["section"]
        section_counts = counts[section]
        totals.update(section_counts)
        print(
            f"  {section:02d} {payload['section_slug']}: "
            f"direct={section_counts['direct']} "
            f"indirect={section_counts['indirect']} "
            f"n/a={section_counts['n/a-js-runtime']} "
            f"total={sum(section_counts.values())}"
        )
    print(
        "Totals: "
        f"direct={totals['direct']} indirect={totals['indirect']} "
        f"n/a={totals['n/a-js-runtime']} total={sum(totals.values())}"
    )
    print(
        "Lifecycle: "
        + " ".join(f"{status}={count}" for status, count in sorted(statuses.items()))
    )
    print(
        f"Traceability: {len(requirement_ids)} requirements, "
        f"{len(test_ids)} tests, {len(mapped_test262)} test262 files, "
        f"{len(example_links)} unique official example links"
    )

    if warnings:
        print(f"Fallback mappings ({len(warnings)}):")
        for warning in warnings:
            print(f"  - {warning}")
    if errors:
        print(f"Audit failures ({len(errors)}):", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1
    print("Conformance traceability audit OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
