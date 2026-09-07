# Elemental reactions — work journal

## Scope and recovery

Base: `feature/data-driven-elemental-reactions` at `3f5539d644ef3deb94443d12e0eb1d0d1c9adc16` (the user-specified `origin/` prefix is a remote-tracking prefix, not part of the branch name).
Working branch: `feature/elemental-reactions-implementation`.
Do not run Godot or `gh`. Runtime verification belongs to the user. Do not modify the GECS submodule or merge the PR.

Read root `CONTEXT.md`, `SKILL.md`, `docs/ARCHITECTURE.md`, `docs/STRICT_TYPING.md`, and the nearest subsystem contexts before changing their code. Preserve typed semantic contracts and the existing combat/effect authority boundaries.

## Architecture decisions

- Prototype tables live inside a typed Resource catalog adapter. Runtime code uses typed definitions and queries, never raw Dictionary tables.
- Independent damage channels and status gauges; a status is active only above its activation threshold. Gauge, remaining duration and source are runtime state. Opposing energy consumes accumulated strength rather than cancelling a status merely because a new type arrives.
- Snapshot initial statuses for damage multipliers. Resolve resistance modifiers, then health damage/healing; status buildup uses the original impact strength independently of damage immunity. Apply gauge changes, then deterministic priority-ordered reactions. Bound chains by depth, action budget and repeated state/rule detection.
- Damage resistance and status immunity are separate. Resistance stacking chooses the strongest positive and negative modifier within each source category, then sums categories and clamps the final value to -1..4.
- Materials are tags/surface definitions, not extra damage enum entries. Environment operations use typed actions; spatial spawning/transformation is handled by an adapter, never by a global gameplay manager.
- Integrate through existing DamageService, EffectService, and GECS systems/observers. Do not replace existing effect lifecycles or Godot physics authority.

## Tasks

- [x] Audit requested branch and read root/combat/effects/ECS contexts and architecture rules.
- [x] Create separate working branch and this recovery journal.
- [x] Read exact damage, ability, effect, ECS and playground contracts; finish integration design.
- [x] Add typed definition records, runtime gauge state and source-addressable resistance API.
- [ ] Implement catalog adapter, prototype rules and resistance/gauge resolution.
- [ ] Implement deterministic resolver, damage/effect bridge and status lifecycle.
- [ ] Implement environment action adapter and sample water/fog/poison/lava rules.
- [ ] Add integration hooks, documentation and regression scenarios.
- [ ] Run non-Godot static/documentation checks; document unverified runtime behavior.
- [ ] Update journal with actual commits and verification; create a separate PR against the requested base branch.

## Commits and checkpoint

- `b5b7e8a` — create recovery journal.
- `2a00577` — link journal from root context.
- `d4b88b8` — typed gauges, rule/action definitions and resistance state (pushed to working branch).
- Latest checkpoint: `d4b88b8e66fdc98249e9355a638f627d087ceef2` plus this journal commit.

The original branch is untouched. No Godot runtime tests have been run. Next: catalog and resolver. Existing DamageRequest constructor is positional; append new optional fields only. O_Damage owns health/death, O_Heal owns healing, EffectRuntime owns effect Entity lifecycles. AbilityResolver and S_Projectile are the delivery entry points; S_EffectTick creates periodic DamageRequest. Do not replace those contracts or modify GECS. All new GDScript must have `##` documentation.
