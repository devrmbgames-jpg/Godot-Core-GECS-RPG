---
name: gecs-v8
description: >
  Design and modify GECS v8 Components, Entities, Systems, Observers, queries, relationships,
  command buffers, and system ordering in this repository. Use whenever code extends Component,
  Entity, System, Observer, QueryBuilder, or touches addons/gecs contracts.
---

# GECS v8

The repository's **pinned submodule is the API authority**. `.gitmodules` tracks GECS v8; the actual checked-out submodule commit wins over upstream `main`.

## Inspect first

When an API is uncertain:
1. inspect `addons/gecs/ecs/` and `addons/gecs/docs/` in the checked-out submodule;
2. inspect existing project usage;
3. only then consult upstream, matching the pinned version.

Do not modify or upgrade the submodule unless the task explicitly requests dependency work.

## Data and behavior

- `Component`: lightweight data/state Resource. No gameplay behavior.
- `Entity`: identity/lifecycle plus allowed Godot scene glue.
- `System`: repeated gameplay/update logic over queries.
- `Observer`: reactive logic for rare component/relationship/query/event transitions.
- Node references to an entity's own children belong on the Entity subclass, not in Components.

## Fast systems

Use `iterate([...])` for hot systems so component arrays arrive directly:

```gdscript
func query() -> QueryBuilder:
    return q.with_all([C_Motion, C_Controller]).iterate([C_Motion, C_Controller])
```

Express ordering with `deps()` when correctness depends on another System. Avoid per-entity `get_component()` lookups inside hot loops when `iterate()` can provide the component.

Structural add/remove during System iteration goes through `cmd` unless the exact pinned implementation and iteration mode make direct mutation safe.

## Observers

Use Observer for discrete/reactive changes, not as a replacement for state machines or per-frame systems.

Pinned v8 supports query modifiers such as:
- `.on_added()`, `.on_removed()`
- `.on_changed([...])`
- `.on_match()`, `.on_unmatch()`
- custom `.on_event(...)`

Property changes are **not automatic**. A Component setter must emit `property_changed` for `on_changed` to fire. Every change dispatch has overhead/payload allocation, so do not emit it for motion/look/physics values that change every frame unless there is a measured need.

Use `cmd` in Observer callbacks when a reaction causes structural mutations or could create recursive event cascades.

## State transitions

For mechanics such as crouch/jump/cast:
- controller/input field = requested intent;
- mechanic component = actual validated state;
- owning System = state transition/validation;
- animation/UI/presentation consumes actual state.

Do not copy intent through redundant relay Components just to preserve layering.
