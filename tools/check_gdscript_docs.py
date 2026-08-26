#!/usr/bin/env python3
"""Check project-owned GDScript functions for adjacent `##` documentation comments.

The checker intentionally excludes `addons/` because GECS is an external submodule.
A function is documented when the nearest preceding non-empty line is a GDScript
Doc Comment (`##`). Run from repository root:

    python tools/check_gdscript_docs.py
"""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXCLUDED_TOP_LEVEL = {"addons", ".git"}
FUNCTION_RE = re.compile(r"^\s*(?:static\s+)?func\s+([A-Za-z0-9_]+)\s*\(")


def project_scripts() -> list[pathlib.Path]:
    """Return all project-owned `.gd` files in deterministic path order."""
    scripts: list[pathlib.Path] = []
    for path in ROOT.rglob("*.gd"):
        relative = path.relative_to(ROOT)
        if relative.parts and relative.parts[0] in EXCLUDED_TOP_LEVEL:
            continue
        scripts.append(path)
    return sorted(scripts)


def undocumented_functions(path: pathlib.Path) -> list[tuple[int, str]]:
    """Return `(line_number, function_name)` entries whose declaration lacks adjacent `##`."""
    lines = path.read_text(encoding="utf-8").splitlines()
    missing: list[tuple[int, str]] = []
    for index, line in enumerate(lines):
        match = FUNCTION_RE.match(line)
        if match is None:
            continue
        previous = index - 1
        while previous >= 0 and not lines[previous].strip():
            previous -= 1
        if previous < 0 or not lines[previous].lstrip().startswith("##"):
            missing.append((index + 1, match.group(1)))
    return missing


def main() -> int:
    """Print documentation gaps and return a CI-friendly non-zero exit code when any exist."""
    failures = 0
    for path in project_scripts():
        for line_number, function_name in undocumented_functions(path):
            failures += 1
            relative = path.relative_to(ROOT)
            print(f"{relative}:{line_number}: function `{function_name}` has no adjacent ## documentation")
    if failures:
        print(f"\nFound {failures} undocumented GDScript function(s).")
        return 1
    print("All project-owned GDScript functions have adjacent ## documentation.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
