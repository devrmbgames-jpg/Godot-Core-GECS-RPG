# ECS Context

GECS integration project-owned layer.

## Layout

- `components/` — данные и relationships; без orchestration.
- `entities/` — reusable Entity types/scenes и их baseline component sets.
- `systems/` — frame/physics processors.
- `observers/` — event/structural reactions.
- `lib/` — stateless helpers/factories/resolvers, когда логика не требует отдельного system state.

## GECS v8 constraints

Pinned GECS v8 находится в `addons/gecs` submodule. Exact relationship target участвует в archetype signature, поэтому instance refs с высокой cardinality не должны без причины становиться targets.

## Canonical relationship shapes

- actor `R_ModifiesStat -> Stat Script`; source item/effect внутри relation data.
- actor `R_HasAbility -> E_Ability Script`; concrete ability Entity внутри relation.
- actor `R_HasEffect -> E_Effect Script`; concrete effect Entity внутри relation.
- actor `R_Equipped -> E_Item Script`; concrete item Entity внутри relation.

## Runtime structural policy

Частые действия не должны постоянно менять archetype. Например `C_Casting` persistent и переключает `active`, вместо add/remove на каждый attack.