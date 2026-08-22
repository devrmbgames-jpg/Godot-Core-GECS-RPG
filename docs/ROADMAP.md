# Roadmap ядра Action RPG

Работа выполняется небольшими независимыми этапами. Каждый этап должен оставлять проект в понятном состоянии и иметь собственную архитектурную границу.

## Этап 1 — Foundation: архитектура, attributes, relationships

- Зафиксировать правила authority и разделение Component / Relationship / Entity / Resource.
- Ввести типизированные атрибуты с `base_value` и закешированным `value`.
- Ввести универсальный `R_ModifiesStat`.
- Пересчитывать stats только для `C_StatsDirty`.
- Автоматически помечать target dirty при добавлении/удалении stat relationship.
- Заложить `R_HasAbility` и `R_OwnedBy` для следующих этапов.

## Этап 2 — Motion, Controller, Input

- Разделить input intent, controller intent и physical motor.
- Player controller и AI controller должны писать в одинаковый `C_MotionIntent`/action intent.
- CharacterBody3D остаётся authority для фактических transform/velocity.
- Плавное ускорение, торможение и поворот через типизированные stats.
- External motion/knockback/impulse не должен уничтожаться player motor'ом.
- Для RigidBody3D использовать силы/импульсы, а не жёстко перезаписывать `linear_velocity` каждый tick.
- Настраиваемый InputMap + отдельный слой binding/profile.

## Этап 3 — Combat и Ability runtime

- `AbilityDefinition` как design-time Resource.
- Ability instance как Entity только там, где нужен runtime state (cooldown, charges, upgrades).
- Attack, Shoot, Fireball.
- Costs, cooldown, attack speed, cast speed, cooldown recovery.
- Targeting/aim, projectile, hit request, damage resolution.
- Instant action — request/event; длительный interruptible cast — component state или Entity, если нужна отдельная identity.

## Этап 4 — Effect system

- EffectDefinition + EffectInstance.
- Poison, Burning, Heal, Regeneration, Buff, Slow.
- Duration/tick/stack/refresh/dispel policies.
- Effects создают stat relationships, damage/heal requests и presentation events; они не знают конкретные managers.

## Этап 5 — Items и Equipment

- ItemDefinition + item entities только при необходимости уникального runtime state.
- Sword, Bow, Staff.
- Equipment slots, ownership, equip/unequip.
- Weapon grants abilities и stat modifiers через relationships.
- Ammo/reload для ranged archetypes при необходимости.

## Этап 6 — Interaction

- `C_Interactable`, interaction intent/request.
- Distance/line-of-sight validation.
- Activate, pickup, lever/door, talk/use hooks.
- Один pipeline для player и AI.

## Этап 7 — Rig и presentation bridge

- Абстрактный `CharacterRig` adapter для готовых моделей.
- AnimationPlayer/AnimationTree, skeleton sockets, weapon anchors.
- Gameplay отправляет semantic requests (`attack`, `cast`, `hit`, `death`), rig переводит их в конкретные animation names.
- VFX/SFX/camera не становятся зависимостями Ability logic.

## Этап 8 — Integration, demo, tests, profiling

- Вертикальный slice: player + AI enemy + melee/ranged/magic + effects + loot/interactions.
- Health/death lifecycle, team/faction, target selection.
- Проверка save/network boundaries.
- Профилирование structural churn и relationship queries.
- Документация extension points для добавления новых abilities/effects/items без изменения центральных systems.

## Механики, добавленные к исходному ТЗ

Для полноценного third-person Action RPG также потребуются: targeting/aim, damage/heal requests, projectiles, cooldown/charges, teams/factions, death lifecycle, equipment slots, effect stacking/dispel rules, hit/impact presentation, locomotion state и единый action-intent слой между Controller и gameplay.
