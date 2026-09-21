---
name: gdscript-format
description: >
  Format and lint project GDScript with GDQuest GDScript Formatter and its VS Code integration.
  Use after editing .gd files, when formatting differs, when CI/style checks fail, or when
  configuring DoHe.godot-format.
---

# GDScript Formatter

Use the GDQuest GDScript Formatter for project-owned GDScript. Prefer the installed/workspace version; do not silently download or upgrade tooling during an unrelated task.

## Scope

Format **changed project-owned `.gd` files first**, not the whole repository. Do not format `addons/gecs` or unrelated vendored/imported code.

## CLI workflow

If `gdscript-formatter` is available:

```bash
gdscript-formatter --check path/to/changed.gd
gdscript-formatter path/to/changed.gd
gdscript-formatter --verify-structure path/to/changed.gd
```

For a batch, pass the narrow changed directory only when that will not touch unrelated files.

After formatting project-owned GDScript also run:

```bash
python tools/check_gdscript_docs.py
```

If the formatter executable is unavailable, report that validation as not run. Do not fabricate output.

## Policy

- Follow the official Godot/GDQuest style produced by the formatter rather than hand-aligning code.
- Preserve semantics; formatting is not an excuse to reorder behavior or refactor unrelated code.
- Keep structure verification enabled.
- Code reordering should remain off by default unless the repository explicitly adopts it.
- Use tabs/spacing as emitted by the configured formatter; avoid manual style wars.

## VS Code

The workspace recommends `DoHe.godot-format`. It bundles formatter support and can format on save. Keep machine-specific paths/settings out of the repository.
