# Effects Context

## Entry points

- `effect_definition.gd` — duration, tick, stacking, instant/periodic values and stat modifiers.
- `effect_service.gd` — typed request API.
- `effect_runtime.gd` — create/refresh/stack/replace/remove runtime Effect Entities and modifiers.
- `ecs/systems/effect/` — tick/duration processing.
- `ecs/observers/effect/` — effect/heal event consumers.
- `demo_effect_catalog.gd` — Poison/Burning/Heal/Regen/Haste/Slow examples.
- `../elemental/CONTEXT.md` — accumulated elemental statuses and reaction actions; these are independent from runtime Effect Entity lifecycle.

## Rules

Effect runtime identity живёт в E_Effect. Stat modifiers source = effect Entity. MORE stacking composes multiplicatively; ADDED/INCREASED scale linearly by stack count.

Periodic effects declare `periodic_damage_type` and `periodic_status_buildup_scale`, then use the same elemental `DamageRequest` pipeline. An elemental reaction may request an Effect by semantic ID through `O_ElementalWorldAction` bindings.

`EffectDefinition.resistance_modifiers` is synchronized to `C_DamageResistances` with a runtime-effect source ID and removed on expiry/replacement. Effect stacks do not multiply integer resistance strength; the resistance resolver still selects the strongest modifier of each sign.
