---
name: agent-continuity
description: >
  Keep long Codex tasks recoverable across context limits, interruptions, model handoffs, and
  multi-session work while minimizing token usage. Use for multi-step refactors, audits, broad
  fixes, or whenever work may outlive the current context window.
---

# Agent continuity and token economy

Repository state is the durable memory. Chat history is not.

## Start/resume

1. Read `CURRENT_WORK.md`.
2. If active, verify branch/head and changed files before doing new exploration.
3. Read only the context/docs explicitly referenced by the checkpoint.
4. Continue from **Next exact step**.
5. If checkpoint and repository disagree, trust repository state and repair the checkpoint.

## During work

Maintain `WORK.md` as a checklist. Update `CURRENT_WORK.md` after a meaningful milestone, before a risky broad change, and before any expected interruption.

Checkpoint only durable information:
- goal and acceptance criteria;
- branch/base;
- changed paths;
- decisions/invariants and why;
- validation already executed;
- unresolved blocker;
- exact next path/symbol/command.

Never paste full logs, diffs, source files, or conversation summaries into checkpoints.

## Token-saving search order

1. root `CONTEXT.md` routing table;
2. nearest subsystem `CONTEXT.md`;
3. exact class/function/path search;
4. direct callers/callees;
5. broader search only if those fail.

Do not repeatedly read unchanged files. Summarize a stable finding once in `CURRENT_WORK.md` when another session will need it.

## Execution rules

- Prefer doing the next verifiable change over writing a long plan.
- Split changes so each milestone can be validated and committed independently.
- Use deterministic scripts/formatters/tests for questions tools can answer.
- Record hypotheses as hypotheses until code/tests prove them.
- If blocked, leave the tree in a coherent state and write the blocker plus the exact evidence needed next.
- Never "save context" by skipping validation or silently changing scope.

## Large tasks

Create `agent_tasks/<name>.md` only when one short checkpoint cannot represent the task. Keep it a checklist and decision record, not a journal.
