# Elemental Reactions Context

Data-driven damage types, accumulated statuses, resistances, reactions and environment actions live here.

## Entry points

- `elemental_catalog.gd` — typed read-only API over raw prototype/CSV-shaped data.
- `prototype_elemental_catalog.gd` — prototype `Dictionary` configuration; gameplay never reads it directly.
- `elemental_resolver.gd` — deterministic impact/status/reaction resolution.
- `elemental_service.gd` — targeted ECS request/event boundary.
- `elemental_action_executor.gd` — executes core actions and publishes world-facing spawn/surface/effect actions.

## Authority

- Immutable rules are typed `Resource` definitions owned by `ElementalCatalog`.
- Runtime buildup/duration is owned by `C_ElementalState` on the affected Entity.
- Damage resistances are owned by `C_DamageResistances`; status immunity is separate in `C_StatusImmunities`.
- Cells, zones, clouds, surfaces, projectiles and actors use the same elemental components. Spatial transforms remain owned by their Godot Nodes.
- Spawn/transform/VFX integration is a typed event boundary. Core rules choose semantic IDs; scene adapters choose PackedScenes and mutate the world.

## Resolution order

1. Snapshot active statuses.
2. Multiply health damage by status multipliers.
3. Resolve final resistance and convert negative damage into healing.
4. Apply armor only to positive health damage.
5. Resolve damage + existing status/material reactions by priority.
6. Accumulate the damage type's linked status from raw impact power.
7. Resolve status + status reactions.
8. Execute ordered actions through a bounded queue.

Reaction chains have both an action budget and a per-reaction fingerprint guard. A reaction may fire once for the same subject/status pair in one root resolution.

## Extension rule

New damage/status/material/reaction IDs are `StringName` data, not enum cases. Add prototype rows now and CSV rows later. New action *kinds* require an executor implementation because they add new runtime behavior.
