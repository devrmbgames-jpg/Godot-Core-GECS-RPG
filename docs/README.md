# Godot Core GECS RPG — документация

Архитектура ядра Action RPG на Godot Engine 4.7 + GECS v8.

Основная цель — не построить набор глобальных `*Manager`, а выразить игровой мир через небольшие данные и независимые processors:

- **Component** — локальное состояние Entity.
- **Relationship** — типизированный факт/связь; relation может содержать данные связи.
- **Entity** — объект с identity/lifecycle.
- **Resource** — преимущественно immutable design-time описание.
- **System** — одно правило изменения состояния.
- **Observer** — реакция на событие/структурное изменение.
- **Godot Node glue** — physics/presentation integration там, где Node уже является естественным authority.

## Навигация для разработчиков и ИИ

- [`../CONTEXT.md`](../CONTEXT.md) — корневая карта проекта: куда идти по типу задачи и какие архитектурные правила нельзя ломать.
- [`../SKILL.md`](../SKILL.md) — workflow/skill работы именно с этим Godot + GECS проектом.
- Ближайшие `CONTEXT.md` внутри `content/*`, `content/ecs/*`, `docs/` и `tools/` — локальные entry points подсистем.
- [`../tools/check_gdscript_docs.py`](../tools/check_gdscript_docs.py) — проверка, что project-owned GDScript functions имеют соседний `##` Doc Comment. `addons/gecs` намеренно исключён как внешняя зависимость.

## Документы

- [PLAYGROUND.md](PLAYGROUND.md) — одна primitive scene со всеми реализованными механиками и controller switching.
- [ROADMAP.md](ROADMAP.md) — этапы реализации ядра.
- [ARCHITECTURE.md](ARCHITECTURE.md) — authority, cardinality и границы ответственности.
- [STRICT_TYPING.md](STRICT_TYPING.md) — typed event/request/result contracts и допустимые Dictionary boundaries.
- [ATTRIBUTES.md](ATTRIBUTES.md) — resolved attributes и modifiers.
- [MOTION_CONTROLLERS_INPUT.md](MOTION_CONTROLLERS_INPUT.md) — Input → Controller → Motion и physics authority.
- [ABILITIES_RELATIONSHIPS.md](ABILITIES_RELATIONSHIPS.md) — ability instances, casts и relationships.
- [COMBAT_ABILITIES.md](COMBAT_ABILITIES.md) — Attack/Shoot/Fireball, projectiles и damage.
- [EFFECTS.md](EFFECTS.md) — Poison/Burning/Heal/Regen/Haste/Slow.
- [ITEMS_EQUIPMENT.md](ITEMS_EQUIPMENT.md) — Sword/Bow/Staff, inventory/equipment.
- [CONTROLLERS_INTERACTION.md](CONTROLLERS_INTERACTION.md) — AI, teams и interaction.
- [RIG_PRESENTATION.md](RIG_PRESENTATION.md) — abstract rig и animation/presentation bridge.
- [DEATH_LIFECYCLE.md](DEATH_LIFECYCLE.md) — death boundary.
- [TESTING.md](TESTING.md) — smoke checklist и validation status.

## Главные правила

1. Hot-path systems читают готовое `C_*.value`; они не пересчитывают effect graph.
2. Ability/item/effect definitions не мутируются runtime modifiers.
3. Godot physics state не зеркалируется в ECS без явного одностороннего sync-contract.
4. Transient action не становится Entity автоматически; Entity оправдана независимым lifecycle.
5. В GECS v8 relationship target cardinality учитывается при проектировании pair keys.
6. Project-owned semantic data не пересекает system/service boundaries как Dictionary: используются typed Request/Event/Result классы.
