# Project Context — Godot Core GECS RPG

Этот файл — первая точка входа для человека или ИИ, который меняет проект. Перед поиском по всему репозиторию прочитайте этот файл, затем ближайший `CONTEXT.md` в нужной подсистеме.

## Что это за проект

Action RPG core на Godot 4.7 + GECS v8. Проект демонстрирует production-oriented границы между ECS gameplay data, Godot physics/scene tree и presentation.

- `addons/gecs` — git submodule, внешняя зависимость. Не изменять в обычных gameplay-задачах.
- `content/` — project-owned runtime/gameplay код.
- `content/ecs/` — Components, Entity types, Systems, Observers и stat/ability helpers.
- `docs/` — архитектурная документация и smoke-checklist.
- `content/test/test.tscn` — primitive integration playground и main scene.

## Куда идти по задаче

| Задача | Сначала читать |
| --- | --- |
| Ability / cast / cooldown / projectile | `content/abilities/CONTEXT.md`, `content/ecs/CONTEXT.md` |
| Damage / teams / combat state / targeting | `content/combat/CONTEXT.md` |
| Attributes / modifiers | `content/stats/CONTEXT.md`, `docs/ATTRIBUTES.md` |
| Effects / buffs / DoT / HoT | `content/effects/CONTEXT.md` |
| Interaction / Area3D selection | `content/interaction/CONTEXT.md` |
| Inventory / equipment / weapons | `content/items/CONTEXT.md` |
| Input / rebinding | `content/input/CONTEXT.md` |
| Player / AI controller | `content/ecs/systems/CONTEXT.md`, `docs/CONTROLLERS_INTERACTION.md` |
| Motion / physics | `content/ecs/systems/CONTEXT.md`, `docs/MOTION_CONTROLLERS_INPUT.md` |
| Rig / animations / presentation | `content/rig/CONTEXT.md` |
| Demo / reproduction | `content/test/CONTEXT.md` |
| Architecture rules | `SKILL.md`, `docs/ARCHITECTURE.md`, `docs/STRICT_TYPING.md` |

## Неподвижные архитектурные правила

1. Godot `CharacterBody3D`/`RigidBody3D` остаются authority физического состояния. Не заводить ECS-копии transform/velocity без явного sync-contract.
2. Hot systems читают готовые `C_*.value`; stat graph пересчитывается dirty-driven, а не при каждом чтении.
3. Design-time definitions — `Resource`; resolved/runtime state — `Component`; независимый lifecycle — `Entity`.
4. Не вводить глобальные AbilityManager/EffectManager/AttributeManager. Используются небольшие services/helpers + GECS Systems/Observers.
5. Project-owned semantic payload не передаётся между подсистемами как `Dictionary`; использовать typed Request/Event/Result классы.
6. GECS v8 exact relationship target влияет на archetype key. High-cardinality Entity refs обычно хранятся в relation/component data, а target пары держится стабильным Script/type.
7. Interaction selection использует `Area3D` overlap, а не постоянный raycast.
8. Projectile swept-ray — осознанное исключение: это collision-delivery, а не interaction/awareness polling.
9. Любой новый project-owned GDScript должен иметь `##` class/file documentation; функции должны иметь `##` contract/intent documentation.

## System order в playground

`Attributes -> Combat -> AI -> Input -> Gameplay -> Presentation` в `_process`, затем `Motion -> Physics` в `_physics_process`.

Не менять порядок без проверки зависимостей: например controller должен заполнить `C_ControllerIntent` до Ability/Interaction, а Motion должен работать до `move_and_slide()`.

## Перед изменением

1. Прочитайте ближайший `CONTEXT.md`.
2. Прочитайте типы данных до System/Observer, который их меняет.
3. Найдите существующий service/event contract и переиспользуйте его.
4. Сверьте `docs/STRICT_TYPING.md` и authority rules.
5. Если добавляется новый маршрут/подсистема — обновите соответствующий `CONTEXT.md`.