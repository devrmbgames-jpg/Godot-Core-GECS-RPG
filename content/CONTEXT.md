# Content Context

`content/` содержит весь project-owned runtime код. Используйте этот файл как router, а затем переходите в ближайший subsystem `CONTEXT.md`.

## Feature directories

- `abilities/` — immutable AbilityDefinition и ability-level events/demo definitions.
- `combat/` — combat query/rules/state/damage contracts.
- `effects/` — EffectDefinition, runtime stacking/ticks and services.
- `input/` — InputProfile и runtime rebinding helper.
- `interaction/` — Area3D target selection, validation, services and drawing presenter.
- `items/` — ItemDefinition, inventory/equipment runtime and services.
- `rig/` — semantic presentation bridge and CharacterRig.
- `stats/` — shared stat modifier definitions.
- `ecs/` — GECS data/processors.
- `test/` — integration playground only; не переносить demo-specific logic в production core.

## Search strategy

Если нужен behavior, сначала найдите definition/component contract в feature directory или `ecs/components`, затем System/Observer. Не начинайте с `test.gd`: playground является consumer core API, а не источником архитектуры.