# Codex / Agent Instructions

This repository is a Godot 4.7 + GECS v8 Action RPG core. This file is the agent entry point. Keep it short; load detailed rules only when the task needs them.

## Start here

1. Read `CURRENT_WORK.md`. If it describes an active matching task, resume from its exact next step.
2. Read root `CONTEXT.md`.
3. Read only the nearest subsystem `CONTEXT.md` named by the routing table in root `CONTEXT.md`.
4. Load only the relevant skill(s) from `.agents/skills/`. Start with at most two; add another only when the task crosses that boundary.
5. Inspect the named implementation files. Prefer exact symbol/path searches over broad repository scans.

Do not reread documents already summarized in `CURRENT_WORK.md` unless they changed or the summary is insufficient.

## Skill router

- Project architecture or any code change: `.agents/skills/project-rules/SKILL.md`
- Godot APIs, scenes, physics, lifecycle: `.agents/skills/godot-4-7/SKILL.md`
- GECS components/systems/observers/queries: `.agents/skills/gecs-v8/SKILL.md`
- GDScript formatting/linting: `.agents/skills/gdscript-format/SKILL.md`
- VS Code/Codex editor workflow: `.agents/skills/vscode-workflow/SKILL.md`
- Tests or test infrastructure: `.agents/skills/gut-testing/SKILL.md`
- Mechanics, balance, progression, game feel, level/pacing decisions: `.agents/skills/professional-game-design/SKILL.md`
- Multi-step work, context pressure, interruption recovery: `.agents/skills/agent-continuity/SKILL.md`

## Non-negotiable project rules

- The version declared by the repository wins. Target Godot 4.7; do not silently use newer APIs.
- `addons/gecs` is a pinned git submodule. Do not modify or upgrade it during normal gameplay work. Verify its local API before using GECS features.
- Components are data. Gameplay behavior belongs in Systems/Observers/services. Entity subclasses may contain scene-tree glue and engine callbacks when that is the simplest Godot integration.
- Keep Node references that point into an entity's own scene on the Entity subclass, not in Component Resources.
- Godot physics bodies own physical transform/velocity unless an explicit sync contract says otherwise.
- Prefer strict GDScript typing. Avoid magic numbers, name shadowing, cyclic dependencies, and stringly-typed semantic payloads.
- Every project-owned GDScript file and meaningful function needs concise `##` documentation according to the existing project rule.
- Do not create parallel manager architectures when an existing service/System/Observer contract already owns the responsibility.
- Do not emit `property_changed` for per-frame hot data unless reactive observation is actually required.
- Never claim a formatter, Godot run, or test passed unless the command actually ran successfully.

## Work protocol

For a sizable task, create/update `WORK.md` before editing. For a long or interruptible task, keep `CURRENT_WORK.md` current after each meaningful milestone. Use `agent_tasks/<task>.md` only when the task is too large for the short tracker.

Make small thematic changes. Validate the narrowest affected surface first. Before finishing:
1. format/check changed GDScript when the formatter is available;
2. run `python tools/check_gdscript_docs.py` after project-owned GDScript changes;
3. run targeted GUT tests when GUT is installed and relevant;
4. broaden testing only when the change warrants it.

Use git directly; do not use `gh`. Do not force-push, rewrite unrelated history, discard user edits, or upgrade dependencies unless requested.

## Token and context budget

- Read routing/context files before code search.
- Read the smallest useful ranges/files; do not dump entire large directories or generated/imported files.
- Search exact class/function/component names first.
- Record durable facts and decisions in project files instead of repeatedly explaining them in chat/logs.
- Keep `CURRENT_WORK.md` factual and compact; never paste full logs or diffs into it.
- If context is becoming large, checkpoint immediately, then continue from the checkpoint rather than reconstructing history.
- Prefer deterministic tools (formatter, tests, static checks) over repeated prose review.
