# Combat Context

## Entry points

- `combat_rules.gd` — team/friendly-fire/enemy semantics.
- `damage_request.gd` / `damage_applied_event.gd` / `damage_service.gd` — typed damage pipeline.
- `combat_state_service.gd` + `ecs/components/combat/c_combat_state.gd` + `ecs/systems/combat/s_combat_state.gd` — combat stance lifetime.
- `combat_awareness.gd` — reads CombatSensor Area3D overlaps.
- `combat_query.gd` / `combat_hit.gd` — Godot physics adapter for explicit ray delivery.

## Combat state

Combat persists while enemy overlaps `CombatSensor` or linger time remains after offensive ability/direct damage. Periodic damage is marked separately so DoT does not keep combat alive forever.

## Physics queries

Ray queries remain appropriate for melee delivery and projectile sweep. Не использовать их как постоянный interaction/awareness polling mechanism.