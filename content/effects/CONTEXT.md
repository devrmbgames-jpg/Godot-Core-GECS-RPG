# Effects Context

## Entry points

- `effect_definition.gd` — duration, tick, stacking, instant/periodic values and stat modifiers.
- `effect_service.gd` — typed request API.
- `effect_runtime.gd` — create/refresh/stack/replace/remove runtime Effect Entities and modifiers.
- `ecs/systems/effect/` — tick/duration processing.
- `ecs/observers/effect/` — effect/heal event consumers.
- `demo_effect_catalog.gd` — Poison/Burning/Heal/Regen/Haste/Slow examples.

## Rules

Effect runtime identity живёт в E_Effect. Stat modifiers source = effect Entity. MORE stacking composes multiplicatively; ADDED/INCREASED scale linearly by stack count.