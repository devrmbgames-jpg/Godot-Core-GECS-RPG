---
name: gut-testing
description: >
  Add and run GUT tests for this Godot 4.7 project, including unit/integration tests, doubles,
  CLI runs, and VS Code GUT integration. Use when adding tests, fixing regressions, installing
  GUT, or validating gameplay Systems and helpers.
---

# GUT testing

This repository currently does not assume GUT is installed. Do not invent passing test results or add the dependency during an unrelated task.

## Version contract

For **Godot 4.7.x**, use **GUT 9.7.1 / the `godot_4_7` branch**. Do not install GUT `main` just because it is newer; its supported Godot version may differ.

When installation is requested, pin the compatible release and record the version. Keep third-party GUT code separate from project tests.

## Test strategy

- Put deterministic pure logic under unit tests first.
- Add integration tests where behavior depends on GECS World/query ordering, Godot Nodes, physics, signals, or Resources.
- One test should explain one behavior/regression.
- Arrange -> act -> assert; name the condition and expected result.
- Prefer real lightweight objects. Use doubles/stubs/spies only at expensive or nondeterministic boundaries.
- For bug fixes, write a regression test that fails for the bug when practical.
- Avoid timing sleeps; await a concrete signal/frame/condition with a bounded timeout.

## Targeted first

Run the smallest relevant test script/suite before the full suite. GUT's CLI entry point is:

```bash
godot -d -s --path "$PWD" addons/gut/gut_cmdln.gd
```

For CI/headless use the local Godot 4.7 executable with headless mode and the same GUT CLI. Prefer a committed `.gutconfig.json` once the project adopts GUT, so editor, VS Code and CLI agree on test directories/options.

The VS Code extension `bitwes.gut-extension` uses GUT's command-line runner and depends on Godot tooling.

## GECS tests

- Test System behavior through minimal matching entities/components.
- Test Observer behavior on the actual event transition, not by calling callbacks manually unless isolating pure helper logic.
- Test system-order-sensitive mechanics with explicit setup/order.
- Avoid testing GECS internals owned by the submodule unless reproducing a project-facing dependency bug.

Always report exactly what command ran and whether failure came from test assertions, parser errors, engine errors, or missing infrastructure.
