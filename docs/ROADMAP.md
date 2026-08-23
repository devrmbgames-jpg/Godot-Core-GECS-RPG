# Roadmap ядра Action RPG

Работа разбита на небольшие архитектурно независимые этапы.

## Статус ветки `feature/arpg-core-foundation`

- ✅ Этап 1 — architecture + attributes + relationships.
- ✅ Этап 2 — configurable input, player/AI controller boundary, motion/physics.
- ✅ Этап 3 — Attack/Shoot/Fireball + cooldown/cast/damage/projectile.
- ✅ Этап 4 — effects: Poison/Burning/Heal/Regen/Haste/Slow.
- ✅ Этап 5 — inventory/equipment: Sword/Bow/Staff.
- ✅ Этап 6 — interaction + teams + minimal AI chase.
- ✅ Этап 7 — abstract CharacterRig + presentation/death bridge.
- 🔶 Этап 8 — integration/profiling: demo scene и smoke checklist добавлены; runtime Godot execution должен быть выполнен локально/CI.

## Этап 1 — Foundation

- Authority rules и разделение Component / Relationship / Entity / Resource.
- Typed attributes с `base_value` + cached `value`.
- `R_ModifiesStat`, dirty rebuild и observer invalidation.

## Этап 2 — Motion, Controller, Input

- Device Input отделён от Player Controller.
- Player/AI приходят к одному `C_ControllerIntent`.
- CharacterBody3D является authority actual velocity/transform.
- RigidBody3D motor использует forces.
- CharacterBody external motion/knockback/contact transfer.
- Runtime InputMap rebinding API.

## Этап 3 — Combat и Ability runtime

- Immutable `AbilityDefinition`.
- Runtime ability Entity только для state (cooldown/owner/grant source).
- Attack, Shoot, Fireball.
- Mana Cost, AttackSpeed, CastSpeed, CooldownRecovery.
- Projectile, targeting seed, damage/armor/death.

## Этап 4 — Effect system

- EffectDefinition + Effect Entity.
- Poison, Burning, Heal, Regeneration, Haste, Slow.
- Duration/tick/stack/refresh/replace/independent policies.
- Effects используют общий stat modifier и damage/heal requests.

## Этап 5 — Items и Equipment

- ItemDefinition + runtime item Entity.
- Sword/Bow/Staff.
- Inventory, equipment slot, stat modifiers, ability grants.

## Этап 6 — Interaction и AI

- Generic interaction request/validation/activation.
- Toggle activatable demo.
- Team/friendly-fire boundary.
- Minimal chase/attack AI через тот же Controller/Ability pipeline.

## Этап 7 — Rig и presentation

- `CharacterRig` Node glue + `RigProfile` Resource.
- Semantic animation actions, sockets, visual equipment, locomotion blend.
- Death presentation/event boundary.

## Этап 8 — Следующая производственная работа

После smoke/profiling ядро стоит развивать вертикальными slices: camera/lock-on targeting, dodge/jump/stamina, hit reactions/poise, combo windows, loot/drop tables, save/load, networking authority, UI/HUD, nav/pathfinding и полноценный AI (Utility/BT/GOAP). Эти механики должны использовать существующие boundaries, а не добавлять центральные managers.
