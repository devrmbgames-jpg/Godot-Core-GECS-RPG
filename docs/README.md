# Godot Core GECS RPG — документация

Этот каталог описывает архитектурные правила ядра Action RPG на Godot Engine 4.7 + GECS.

Основная цель проекта — не построить набор глобальных `*Manager`, а выразить игровой мир через небольшие данные и независимые системы:

- **Component** — состояние конкретной сущности.
- **Relationship** — типизированная связь между сущностями; данные relation принадлежат самой связи.
- **Entity** — объект с собственной identity/lifecycle.
- **Resource** — преимущественно неизменяемое design-time описание.
- **System** — одно правило изменения данных.
- **Observer** — реакция на структурное событие без постоянного polling.

## Документы

- [ROADMAP.md](ROADMAP.md) — этапы реализации ядра.
- [ARCHITECTURE.md](ARCHITECTURE.md) — общие правила и границы ответственности.
- [ATTRIBUTES.md](ATTRIBUTES.md) — атрибуты, модификаторы и runtime resources.
- [ABILITIES_RELATIONSHIPS.md](ABILITIES_RELATIONSHIPS.md) — abilities, relationships, casts, effects и presentation bridge.

## Главные правила

1. Hot-path системы читают **готовое значение** (`C_MoveSpeed.value`, `C_Armor.value`), а не пересчитывают дерево эффектов.
2. Статические значения ability/item хранятся в `Resource`; их нельзя мутировать временными эффектами.
3. Godot physics state (`CharacterBody3D.velocity`, transform, `RigidBody3D.linear_velocity`) не дублируется в ECS без явной причины.
4. Тяжёлый временный игровой объект (projectile, сложный effect, длительный cast) может быть `Entity`; мгновенное действие обычно является request/event.
5. Relationship не заменяет Component. Он используется, когда важны source/target и/или данные принадлежат связи.
