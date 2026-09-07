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

- [x] Audit requested branch, recover existing six-commit work branch and checkpoint history.
- [x] Read root/combat/effects/ECS/ability contexts and architecture rules.
- [x] Add typed definitions, gauges, resistance API, catalog adapter and direct status request.
- [x] Implement pure damage/status resolution and bounded reaction interpreter.
- [x] Extend DamageRequest with optional elemental fields without changing old positional arguments.
- [ ] Complete prototype data normalization/validation and environment definitions.
- [ ] Integrate signed damage/healing, direct status events, ability/projectile/DoT delivery and effect lifecycle.
- [ ] Implement spatial action adapter and concrete water/fog/poison/lava examples.
- [ ] Add actor/environment components, playground integration, documentation and regression scenarios.
- [ ] Run non-Godot static/documentation checks; record unverified runtime behavior.
- [ ] Review diff, update this journal and create a separate PR against the requested base.

## Commits and checkpoint

- `b5b7e8a`, `2a00577`, `d4b88b8` — original recovery journal/context and typed groundwork.
- `c14baa52` — recovered existing six-commit head.
- `9b35e5de` — recovery checkpoint.
- `9c469fb0` — catalog adapter, gauge invariants, typed request/result helpers.
- `670e2b32` — direct status request.
- `44ce5b2f` — shared chain budget.
- `2f4630c8` — typed resolution context.
- `57d690b5` — damage/status/tick resolver.
- `0e5a33a2` — prioritized reaction interpreter.
- `0f5a9517` — backward-compatible DamageRequest extension (latest checkpoint).

Next: finish the catalog and integrate the resolver with existing combat/effect contracts. The branch is intentionally in active development; Godot runtime and full-project documentation checks have not been run. Do not claim completion until integration, tests, and PR are finished. Existing EffectRuntime.apply/remove and O_Heal are the canonical lifecycle/healing paths. AbilityResolver and S_Projectile are delivery entry points; S_EffectTick produces periodic DamageRequest.
