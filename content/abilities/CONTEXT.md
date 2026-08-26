# Abilities Context

## Entry points

- `ability_definition.gd` — immutable design contract: delivery, timing, cost, damage, projectile, effects, presentation.
- `demo_ability_catalog.gd` — Attack/Shoot/Fireball sample definitions.
- `ability_resolved_event.gd` — typed resolved event.
- `../ecs/lib/ability_factory.gd` — grants/revokes/finds runtime ability instances.
- `../ecs/systems/ability/` — intent, activation, casting, cooldown.
- `../ecs/lib/ability_resolver.gd` — delivery resolution.

## Rules

Definitions не мутируются runtime modifiers. Cost/cooldown/cast work рассчитываются из actor stats во время execution. Player attack/cast uses cursor aim from `C_ControllerIntent`; AI uses its controller target/facing.