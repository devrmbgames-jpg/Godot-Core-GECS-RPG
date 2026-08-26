---
name: godot-gecs-rpg-project
description: Work safely and efficiently on the Godot 4.7 + GECS v8 Action RPG core in this repository. Use for architecture, GDScript, ECS systems/components/observers, abilities, combat, effects, items, interaction, motion, rig and playground changes.
---

# Godot + GECS Action RPG Project Skill

## Mission

Изменять проект небольшими, проверяемыми шагами, сохраняя уже выбранные архитектурные границы. Не заменять рабочую архитектуру более «универсальными» manager-объектами и не дублировать Godot physics state в ECS без необходимости.

## Required reading order

1. `CONTEXT.md` в корне.
2. Ближайший `CONTEXT.md` в подсистеме задачи.
3. Связанный документ из `docs/`.
4. Только затем конкретные `.gd`.

Это предпочтительнее широкого code search: контекстные файлы перечисляют canonical entry points.

## Dependency boundary

`addons/gecs` — pinned submodule GECS v8. Не редактировать его для gameplay feature/fix. Если API GECS непонятен, сначала проверить pinned implementation; upgrade dependency — отдельная задача.

## Data placement decision

Перед добавлением типа определить его категорию:

- immutable design data -> `Resource`;
- resolved/modifiable actor value -> `Component`;
- runtime state -> `Component`;
- independent identity/lifecycle -> `Entity`;
- physical transform/velocity -> Godot body unless explicit ECS authority is justified;
- transient cross-system semantic message -> typed `RefCounted` Request/Event/Result.

## GECS rules

- Systems содержат одно правило обновления; Observers реагируют на events/structural changes.
- Не делать frequent add/remove Components, если состояние может быть persistent component с `active` flag.
- Для relationships избегать high-cardinality exact Entity targets. Например actor `R_ModifiesStat -> C_Damage`, а source item/effect хранится внутри relation data.
- Ability/effect/item runtime instances могут жить off-tree, если им не нужен spatial Node lifecycle.

## Attribute rules

- `base_value` — design/base layer; `value` — resolved cache.
- `C_Health.current` не заменяет `C_MaxHealth.value`; аналогично Mana.
- Modifier formula: `(base + added) * (1 + increased) * product(more)`.
- Изменение modifiers помечает stats dirty; hot path не вызывает resolver вручную на каждом чтении.

## Controller and motion rules

- Device input -> `C_InputState` -> Player/AI Controller -> common `C_ControllerIntent`.
- Motion/Ability/Interaction не должны зависеть от конкретного input device или AI implementation.
- `CharacterBody3D.velocity` и `RigidBody3D.linear_velocity` — physical authority.
- Character motor контролирует только свою horizontal contribution; external motion хранится отдельно.
- Rigid motor работает force/torque-based, не overwrite `linear_velocity`.
- В combat state player facing следует cursor aim; backpedal имеет multiplier.

## Combat and ability rules

- `AbilityDefinition` immutable; cooldown/cast/mana находятся в runtime Components/Entities.
- Offensive activation обновляет `C_CombatState`.
- Direct damage удерживает combat state, periodic damage не должен бесконечно удерживать его.
- Damage/effects обязаны проходить `CombatRules` для team/friendly-fire semantics.
- Projectile position принадлежит Node3D; swept-ray допустим для быстрых projectile collisions.

## Interaction rules

- Actor имеет `InteractionSensor` (`Area3D`) + `C_InteractionSensor`.
- Player selection выбирает ровно один ближайший валидный interactable из overlaps.
- Нажатие interact активирует уже selected target; не запускает новый raycast/search.
- AI не обязан брать ближайший target: behavior пишет `C_AIInteractionGoal`, selection только проверяет доступность цели.
- Highlight — optional presentation capability через `C_InterractDrawing`; gameplay interaction не зависит от visual.

## Presentation rules

Gameplay публикует semantic `PresentationActionEvent` через `PresentationService.publish`; `CharacterRig` решает, какая animation/model/socket соответствует action.

Не вызывать несуществующие convenience methods по памяти: перед новым presentation call открыть `content/rig/presentation_service.gd` и `presentation_action_event.gd`.

## Documentation rule

Каждый project-owned `.gd` должен быть пригоден как reusable code:

- `##` перед class/file purpose;
- `##` перед public API и значимыми private helpers;
- документировать authority, side effects, ownership, units/ranges и важные invariants;
- не писать комментарий, который просто повторяет имя функции;
- при изменении contract обновлять doc comment и ближайший `CONTEXT.md`.

## Workflow

1. Audit current branch/head; не считать старую feature branch актуальной.
2. Делать новую branch от актуального default branch для крупной задачи.
3. Изменять небольшими тематическими commits.
4. Не утверждать, что Godot runtime test прошёл, если executable реально не запускался.
5. После изменения проверять references/call sites и docs, особенно typed API names.