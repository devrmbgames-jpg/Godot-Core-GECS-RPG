---
name: vscode-workflow
description: >
  Work on this Godot project through VS Code with Codex, Godot Tools, GDScript Formatter,
  and optional GUT integration. Use when setting up the editor, debugging extension/LSP
  behavior, choosing workspace settings, or preparing the local Codex workflow.
---

# VS Code workflow

VS Code is the editor host, not project authority. Repository configuration should be portable across developer machines.

## Recommended extensions

The workspace `.vscode/extensions.json` recommends:
- `openai.chatgpt` — official Codex/ChatGPT extension
- `geequlim.godot-tools` — Godot/GDScript language tooling
- `DoHe.godot-format` — GDQuest formatter integration
- `bitwes.gut-extension` — GUT test integration when GUT is installed

## Local-only settings

Configure the Godot executable/editor path locally if needed. Do **not** commit absolute Windows/macOS/Linux executable paths, API keys, account data, or user-specific launch settings.

## Codex context discipline

- Open/select the smallest relevant source range when asking about local code.
- Let `AGENTS.md` route Codex to project context and skills rather than pasting architecture into every prompt.
- For long work, update `CURRENT_WORK.md` so a new Codex context can resume from repository state.
- Keep source-of-truth decisions in `CONTEXT.md`/docs, not only in chat.

## Editing loop

1. Inspect local diagnostics before editing.
2. Make one coherent change.
3. Format changed GDScript.
4. Run static docs check and targeted tests.
5. Review the diff for unrelated formatter/scene churn.
6. Update work checkpoint before switching tasks or exhausting context.

Do not modify `.godot/`, imported generated data, or extension caches.
