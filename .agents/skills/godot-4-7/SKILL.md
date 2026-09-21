---
name: godot-4-7
description: >
  Implement and debug this project's Godot Engine 4.7 code, scenes, physics, Resources,
  Node lifecycle, and 3D APIs. Use when editing .gd/.tscn/project.godot or choosing a Godot
  API whose behavior may vary by engine version.
---

# Godot 4.7

Target the project's declared Godot **4.7** API. Do not substitute latest-version examples without checking compatibility.

## Before editing

- Confirm `project.godot` still declares 4.7.
- Inspect the local scene/script contract before changing node ownership.
- For version-sensitive API details, use Godot 4.7 documentation or the installed engine API, not memory of another minor release.

## Runtime rules

- Physics simulation and body mutations belong on the physics step.
- For controlled `RigidBody3D` behavior, prefer forces/impulses and `_integrate_forces(state: PhysicsDirectBodyState3D)` when direct physics-state integration is required.
- Do not overwrite RigidBody transform/velocity every render frame and fight the solver.
- Keep gravity, collision response, friction and bounce in the physics engine unless the mechanic explicitly requires custom integration.
- Use `_process` for presentation/render-rate work and physics callbacks for simulation.
- Distinguish local and global transforms; preserve coordinate-space intent.
- Use Node references as scene glue on Entity/Node classes. Keep reusable configuration/data in Resources/Components.

## GDScript 4.x

- Use `@export`, `@onready`, typed signals and `await`.
- Prefer `StringName` for stable action/property identifiers used repeatedly.
- Use `is_zero_approx()`, `clampf/minf/maxf` and typed math where appropriate.
- Avoid frame-rate dependent rates: multiply continuous rates by the correct step; do not multiply accumulated mouse relative deltas by delta.

## Scenes and resources

- Avoid editing imported/generated artifacts when the source asset or scene is authoritative.
- Do not invent Node paths: inspect the scene first.
- Do not use machine-local absolute paths in committed project files.

## Physics extension pattern

A project Entity may expose Godot callbacks and delegate logic to a System:

```gdscript
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    S_Motion.integrate_forces(self, state)
```

This is acceptable here: Godot integration glue stays thin while gameplay logic remains in the System.
