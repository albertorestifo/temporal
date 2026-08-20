#!/usr/bin/env python3
"""Validate the machine-readable Temporal conformance inventory."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFORMANCE = ROOT / "conformance"
COVERAGE = CONFORMANCE / "coverage"
REQUIREMENT_ID = re.compile(r"^TEMP-S(\d{2})-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
GLEAM_TEST_ID = re.compile(
    r"^[a-z][a-z0-9_/]*::[a-z][a-z0-9_]*_test$"
)
SHA = re.compile(r"^[0-9a-f]{40}$")
DISPOSITIONS = {"direct", "indirect", "n/a-js-runtime"}
STATUSES = {"planned", "active", "complete", "exempt"}
REQUIRED_REQUIREMENT_FIELDS = {
    "id",
    "spec_anchor",
    "spec_url",
    "summary",
    "disposition",
    "coverage_status",
    "gleam_test_ids",
    "test262_paths",
    "official_example_links",
    "rationale",
}


def load_json(path: Path, errors: list[str]) -> dict:
    try:
        return json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as exception:
        errors.append(f"{path.relative_to(ROOT)}: cannot load JSON: {exception}")
        return {}


def validate_sources(errors: list[str]) -> dict:
    path = CONFORMANCE / "sources.json"
    metadata = load_json(path, errors)
    sources = metadata.get("sources", {})
    expected = {"temporal_spec", "proposal_docs", "test262"}
    if set(sources) != expected:
        errors.append(
            f"conformance/sources.json: sources must be exactly {sorted(expected)}"
        )
    for name, source in sources.items():
        commit = source.get("commit", "")
        if not SHA.fullmatch(commit):
            errors.append(f"conformance/sources.json: {name} has no immutable SHA")
        for key in ("commit_url", "source_url"):
            url = source.get(key, "")
            if commit not in url:
                errors.append(
                    f"conformance/sources.json: {name}.{key} is not pinned to {commit}"
                )
        cookbook_url = source.get("cookbook_url")
        if cookbook_url is not None and commit not in cookbook_url:
            errors.append(
                f"conformance/sources.json: {name}.cookbook_url is not pinned to {commit}"
            )
        notice = source.get("notice")
        if not notice or not (CONFORMANCE / notice).is_file():
            errors.append(
                f"conformance/sources.json: {name} notice does not exist: {notice!r}"
            )
    return metadata


def validate_requirement(
    requirement: dict,
    section: int,
    proposal_sha: str,
    seen_requirement_ids: set[str],
    seen_test_ids: set[str],
    seen_test262_paths: set[str],
    errors: list[str],
) -> None:
    label = requirement.get("id", "<missing-id>")
    missing = REQUIRED_REQUIREMENT_FIELDS - set(requirement)
    if missing:
        errors.append(f"{label}: missing fields {sorted(missing)}")
        return

    requirement_id = requirement["id"]
    match = REQUIREMENT_ID.fullmatch(requirement_id)
    if not match or int(match.group(1)) != section:
        errors.append(f"{label}: invalid or wrong-section requirement ID")
    if requirement_id in seen_requirement_ids:
        errors.append(f"{label}: duplicate requirement ID")
    seen_requirement_ids.add(requirement_id)

    anchor = requirement["spec_anchor"]
    if not isinstance(anchor, str) or not anchor.strip():
        errors.append(f"{label}: missing valid spec anchor")
    spec_url = requirement["spec_url"]
    if proposal_sha not in spec_url or not spec_url.endswith(f"#{anchor}"):
        errors.append(f"{label}: spec URL is not immutable or does not match anchor")

    disposition = requirement["disposition"]
    if disposition not in DISPOSITIONS:
        errors.append(f"{label}: invalid disposition {disposition!r}")
    status = requirement["coverage_status"]
    if status not in STATUSES:
        errors.append(f"{label}: invalid coverage status {status!r}")
    if disposition == "n/a-js-runtime":
        if status != "exempt":
            errors.append(f"{label}: N/A requirement must have exempt status")
        if not isinstance(requirement["rationale"], str) or not requirement[
            "rationale"
        ].strip():
            errors.append(f"{label}: N/A requirement needs a rationale")
    elif requirement["rationale"] is not None:
        errors.append(f"{label}: applicable requirement rationale must be null")

    test_ids = requirement["gleam_test_ids"]
    if not isinstance(test_ids, list) or not all(
        isinstance(test_id, str) and GLEAM_TEST_ID.fullmatch(test_id)
        for test_id in test_ids
    ):
        errors.append(
            f"{label}: Gleam test IDs must use module/path::function_test format"
        )
        test_ids = []
    if disposition != "n/a-js-runtime" and status in {"active", "complete"} and not test_ids:
        errors.append(f"{label}: active requirement has no Gleam test ID")
    for test_id in test_ids:
        if test_id in seen_test_ids:
            errors.append(f"{label}: duplicate Gleam test ID {test_id!r}")
        seen_test_ids.add(test_id)

    paths = requirement["test262_paths"]
    if not isinstance(paths, list) or not all(
        isinstance(path, str) and path.startswith("test/built-ins/Temporal/")
        for path in paths
    ):
        errors.append(f"{label}: invalid test262_paths")
        paths = []
    for path in paths:
        if path in seen_test262_paths:
            errors.append(f"{label}: duplicate test262 path {path!r}")
        seen_test262_paths.add(path)

    links = requirement["official_example_links"]
    if not isinstance(links, list) or not all(
        isinstance(link, str) and proposal_sha in link for link in links
    ):
        errors.append(f"{label}: example links must be immutable proposal URLs")


def main() -> int:
    errors: list[str] = []
    metadata = validate_sources(errors)
    proposal_sha = (
        metadata.get("sources", {}).get("temporal_spec", {}).get("commit", "")
    )
    expected_paths: dict[int, Path] = {}
    for path in sorted(COVERAGE.glob("*.json")):
        match = re.match(r"^(\d{2})-", path.name)
        if not match:
            errors.append(f"{path.relative_to(ROOT)}: filename needs a section prefix")
            continue
        section = int(match.group(1))
        if section in expected_paths:
            errors.append(f"conformance/coverage: duplicate section file {section}")
        expected_paths[section] = path
    missing_sections = set(range(1, 16)) - set(expected_paths)
    extra_sections = set(expected_paths) - set(range(1, 16))
    if missing_sections:
        errors.append(f"conformance/coverage: missing sections {sorted(missing_sections)}")
    if extra_sections:
        errors.append(f"conformance/coverage: unexpected sections {sorted(extra_sections)}")

    seen_requirement_ids: set[str] = set()
    seen_test_ids: set[str] = set()
    seen_test262_paths: set[str] = set()
    for section in sorted(set(range(1, 16)) & set(expected_paths)):
        path = expected_paths[section]
        coverage = load_json(path, errors)
        if coverage.get("section") != section:
            errors.append(f"{path.relative_to(ROOT)}: section number does not match filename")
        section_anchor = coverage.get("section_anchor")
        requirements = coverage.get("requirements")
        if not section_anchor or not isinstance(section_anchor, str):
            errors.append(f"{path.relative_to(ROOT)}: missing section anchor")
        if not isinstance(requirements, list) or not requirements:
            errors.append(f"{path.relative_to(ROOT)}: requirements must not be empty")
            continue
        anchors = {item.get("spec_anchor") for item in requirements if isinstance(item, dict)}
        if section_anchor not in anchors:
            errors.append(
                f"{path.relative_to(ROOT)}: section anchor has no requirement record"
            )
        section_url = coverage.get("section_url", "")
        if proposal_sha not in section_url or not section_url.endswith(
            f"#{section_anchor}"
        ):
            errors.append(f"{path.relative_to(ROOT)}: section URL is not immutable")
        for requirement in requirements:
            if not isinstance(requirement, dict):
                errors.append(f"{path.relative_to(ROOT)}: requirement is not an object")
                continue
            validate_requirement(
                requirement,
                section,
                proposal_sha,
                seen_requirement_ids,
                seen_test_ids,
                seen_test262_paths,
                errors,
            )

    manifest = load_json(CONFORMANCE / "test262-manifest.json", errors)
    expected_test262_count = manifest.get("path_count")
    if manifest.get("source_commit") != (
        metadata.get("sources", {}).get("test262", {}).get("commit")
    ):
        errors.append("conformance/test262-manifest.json: source commit does not match pin")
    if expected_test262_count != len(seen_test262_paths):
        errors.append(
            "conformance/test262-manifest.json: mapped path count "
            f"{len(seen_test262_paths)} does not equal manifest count {expected_test262_count}"
        )
    if manifest.get("unmatched_path_count") != 0 or manifest.get("unmatched_paths"):
        errors.append("conformance/test262-manifest.json: contains unmapped Temporal tests")

    if errors:
        print("Conformance inventory check failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1
    print(
        "Conformance inventory OK: "
        f"15 sections, {len(seen_requirement_ids)} requirements, "
        f"{len(seen_test_ids)} Gleam tests, {len(seen_test262_paths)} test262 files"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
