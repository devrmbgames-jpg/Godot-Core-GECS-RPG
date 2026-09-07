# Abilities Context

## Entry points

- `ability_definition.gd` — immutable design contract: delivery, timing, cost, damage, projectile, effects and presentation scenes.
- `demo_ability_catalog.gd` — Attack/Shoot/Fireball sample definitions; Fireball selects prototype flight/impact VFX here.
- `ability_resolved_event.gd` — typed resolved event.
- `../ecs/lib/ability_factory.gd` — grants/revokes/finds runtime ability instances.
- `../ecs/systems/ability/` — intent, activation, casting, cooldown.
- `../ecs/lib/ability_resolver.gd` — delivery resolution and semantic presentation `resolve` phase.

## Rules

Definitions не мутируются runtime modifiers. Cost/cooldown/cast work рассчитываются из actor stats во время execution. Player attack/cast uses cursor aim from `C_ControllerIntent`; AI uses its controller target/facing.

Projectile VFX является presentation data: `projectile_visual_scene` следует за projectile Entity, а `impact_vfx_scene` спавнится отдельно на collision. Ни одна scene не владеет damage/collision logic.
