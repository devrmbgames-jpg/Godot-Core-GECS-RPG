# Elemental reactions — work journal

## Recovery and constraints

Base: `feature/data-driven-elemental-reactions` at `3f5539d644ef3deb94443d12e0eb1d0d1c9adc16`. Working branch: `feature/elemental-reactions-implementation`. The original branch is untouched. Do not run Godot or `gh`, modify the GECS submodule, or merge the PR. Runtime verification belongs to the user.

Read root `CONTEXT.md`, `SKILL.md`, `docs/ARCHITECTURE.md`, `docs/STRICT_TYPING.md`, and the nearest subsystem contexts before changes. Preserve typed semantic contracts and existing combat/effect/physics authority boundaries.

## Architecture

- Dictionary prototype tables are converted to typed Resource definitions through ElementalCatalog; gameplay reads typed APIs.
- C_ElementalState owns independent gauges, durations, material/tags, status immunities and source-addressable resistance modifiers. NONE is absence of active statuses, not a gauge.
- Damage multipliers and resistance use the pre-impact active-status snapshot. Buildup uses original impact strength, independently of damage resistance and armor. Opposing gauges exchange equal strength, preserving residual buildup.
- Resistance stacking selects strongest positive and negative modifiers per category, sums categories with the base and clamps -1..4. Status immunity is independent.
- ElementalResolver and ElementalReactionEngine mutate only state and return typed action intents. Rules are priority-descending/id-ascending, re-evaluated after mutations, executed at most once per impact, with repeated-state and action/depth budgets.
- Materials are tags/surfaces rather than damage enum entries. Spatial operations must be handled by an adapter, not a global gameplay manager.
- O_Damage owns HP/death, O_Heal owns healing, EffectRuntime owns Effect Entity lifecycles. Preserve existing positional DamageRequest arguments and GECS event contracts.

## Tasks

- [x] Audit requested branch and recover existing work without rewriting history.
- [x] Add typed definitions, gauges, resistance API, catalog adapter and direct status request.
- [x] Implement initial damage/status resolution and bounded reaction interpreter.
- [x] Extend DamageRequest and connect signed damage/healing and direct status/environment observers.
- [x] Add initial environment profile data and typed ElementalService.
- [ ] Correct gauge refresh, finite-value validation, reaction no-ops, deterministic priorities and chain limits.
- [ ] Complete catalog normalization/validation and prototype reaction data.
- [ ] Integrate ability/projectile/DoT delivery and gauge-owned effect lifecycle without duplicated ownership.
- [ ] Implement spatial action adapter, zone Entity, Area3D overlap pulses and material transformation.
- [ ] Add actor/environment components, playground integration, documentation and regression scenarios.
- [ ] Run non-Godot static/documentation checks; record unverified runtime behavior.
- [ ] Review diff, update this journal and create a separate PR against the requested base.

## Commits and checkpoint

- `b5b7e8a`, `2a00577`, `d4b88b8` — original recovery journal/context and typed groundwork.
- `c14baa52` — recovered existing six-commit head.
- `9b35e5de` — recovery checkpoint.
- `9c469fb0` — catalog adapter, gauge invariants and typed helpers.
- `670e2b32`, `44ce5b2f`, `2f4630c8` — status request, chain and result contracts.
- `57d690b5`, `0e5a33a2` — initial resolver and reaction engine.
- `0f5a9517` — backward-compatible DamageRequest extension.
- `03efc00f`, `19c3ca9d`, `67576a3f`, `11e17bec` — combat integration and source checkpoint.
- `2276c48f`, `e5b25b8c`, `ac7a3247`, `fbc3ca7f`, `10a94b5d` — typed service and environment/status observers.
- `96f49ad5`, `d224bb67`, `0cde71ae`, `13df75cd` — initial environment definitions and latest service fixes.
- Resumed from `13df75cd4fc690fe265df06ca9a473d5e9278b64`, 27 commits ahead of base.

## Current findings / next step

The existing gauge stops refreshing at its maximum; fix this and make duration changes observable. The reaction interpreter can fire no-op rules and emit spawns without actual consumption. The catalog accepts invalid enum casts and unchecked numeric/reference values. Complete those contracts before spatial integration. The environment profiles exist, but no world action adapter or zone runtime exists yet. Existing EffectRuntime.apply/remove and O_Heal remain canonical lifecycle/healing paths. AbilityResolver and S_Projectile are delivery entry points; S_EffectTick produces periodic DamageRequest. The branch is intentionally in active development. No Godot runtime checks or complete static checks have been run.
