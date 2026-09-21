# Work Tracker

Use this as a durable checklist for the current implementation task. Keep completed items concise; detailed history belongs in git.

## Active

- [ ] No active implementation task.

## Agent infrastructure

- [x] Add Codex `AGENTS.md` entry point.
- [x] Add project-local skills under `.agents/skills/`.
- [x] Add interruption recovery files.
- [x] Add VS Code extension recommendations and safe workspace settings.
- [ ] Install/configure GUT 9.7.1 only when tests are explicitly being introduced.

## Rules

- Break large work into independently verifiable steps.
- Mark an item complete immediately after validation, not at the end of the whole task.
- If a task spans many files or sessions, create `agent_tasks/<task-name>.md` and link it here.
- Do not duplicate full diffs, terminal logs, or conversation history.
