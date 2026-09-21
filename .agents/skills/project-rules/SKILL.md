---
name: project-rules
description: >
  Work safely in Godot-Core-GECS-RPG using its architecture, context routing, typing,
  documentation, physics authority, and change-validation rules. Use for every gameplay
  feature, refactor, bug fix, or architecture change in this repository.
---

# Project rules

Use this skill as the repository-specific layer. Engine/framework details belong to their own skills.

## Workflow

1. Read root `CONTEXT.md`.
2. Follow its routing table to the nearest subsystem `CONTEXT.md`.
3. Read the data contracts before the System/Observer that mutates them.
4. Reuse an existing service/event/request contract before creating a new one.
5. Make the smallest coherent change and validate its direct callers.

## Architecture

- Godot physical bodies are authority for physical transform/velocity unless a documented sync contract explicitly says otherwise.
- Design-time immutable definitions are `Resource`; mutable runtime actor state is `Component`; independent identity/lifecycle is `Entity`.
- Keep Components data-only. Put behavior in Systems/Observers/services.
- Entity subclasses are allowed as Godot glue: child Node references, engine callbacks, and thin forwarding into Systems are acceptable when they avoid awkward ECS plumbing.
- Do not place references to an entity's own scene children in Component Resources.
- Prefer typed Request/Event/Result classes over project-owned semantic `Dictionary` payloads.
- Do not introduce global Ability/Effect/Attribute managers alongside the existing architecture.
- Visual model, equipment props, VFX, camera and animation presentation are not gameplay authority.
- Respect the existing system ordering documented in `CONTEXT.md`; express new dependencies explicitly rather than relying on accidental scene order.

## GECS boundary

`addons/gecs` is a submodule. Normal project tasks must not modify it. If GECS behavior is unclear, inspect the pinned submodule implementation and its docs before searching upstream.

## GDScript quality

- Prefer explicit types on public/stateful APIs and ambiguous local values.
- Avoid cyclic script dependencies, class-name collisions, shadowing native/classes, and magic constants.
- Keep hot paths allocation-light.
- Every project-owned `.gd` has a concise `##` file/class purpose and meaningful functions have contract/intent documentation.
- Update the nearest `CONTEXT.md` when a subsystem contract or canonical entry point changes.

## Validation

After project-owned GDScript changes:
```bash
python tools/check_gdscript_docs.py
```

Also run the formatter and the narrowest relevant tests when available. Never report runtime validation that was not actually executed.
