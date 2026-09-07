# Work Log — Data-driven Elemental Reactions

Этот файл фиксирует текущий прогресс разработки. Архитектурные решения и публичные контракты после завершения переносятся в `docs/ELEMENTAL_REACTIONS.md` и ближайшие `CONTEXT.md`.

## Цель

Добавить расширяемую data-driven систему типизированного урона, накопительных статусов, резистов, реакций и воздействий окружения для Godot 4.x / GECS v8.

## Ограничения

- Базовая ветка: `origin/feature/data-driven-elemental-reactions`.
- Рабочая ветка: `codex/data-driven-elemental-reactions`.
- Не изменять `addons/gecs`.
- Не запускать Godot; runtime-проверку выполняет владелец проекта.
- Gameplay-код не обращается к raw `Dictionary`; доступ к prototype data идёт через API-каталог.
- Новые semantic request/result/action types остаются типизированными.

## Текущие задачи

- [x] Прочитать корневой и профильные `CONTEXT.md`, `SKILL.md`, `ARCHITECTURE.md`, `STRICT_TYPING.md`.
- [x] Создать рабочую ветку и журнал прогресса.
- [x] Описать design/runtime модель и допущения.
- [x] Добавить идентификаторы, definitions и API-каталог prototype-конфигурации.
- [x] Добавить runtime-компоненты статусов, резистов и материалов окружения.
- [x] Реализовать детерминированный resolver с лимитом цепочки реакций.
- [x] Интегрировать resolver с существующим typed damage pipeline без поломки generic damage.
- [x] Добавить action executor hooks для spawn/transform/presentation.
- [x] Добавить электрическую воду, влажный туман и ядовитое облако в prototype data.
- [ ] Добавить тестовые сценарии без запуска Godot.
- [ ] Обновить `CONTEXT.md` и документацию.
- [ ] Запустить `python tools/check_gdscript_docs.py` и другие доступные статические проверки.
- [ ] Отправить ветку и открыть отдельный PR в `feature/data-driven-elemental-reactions`.

## Принятые решения

- Статус хранит `buildup`, активность и оставшуюся длительность отдельно; накопление ниже порога не обязано означать активный статус.
- Противоположные воздействия сначала расходуют накопление пропорционально силе, поэтому слабый холод не снимает сильное горение.
- Итоговый damage resistance: `clamp(base + strongest_negative + strongest_positive, -1, 4)`; источники одного знака не суммируются.
- Реакции возвращают упорядоченный список типизированных действий. Resolver обрабатывает очередь с budget/depth guard и fingerprint guard.
- Материалы окружения представлены тегами на damageable/status-bearing subject; зона/клетка/облако/снаряд используют тот же subject contract, что и actor.

## Журнал

- 2026-09-07: аудит ветки и архитектурных правил; создана рабочая ветка и этот журнал.
- 2026-09-07: добавлены открытые StringName ID, typed Resource definitions, каталог-обёртка и полная prototype Dictionary-конфигурация множителей/резистов/реакций.
- 2026-09-07: добавлены накопительный runtime status state, отдельные status immunities, resistance profile/modifiers и material tags; реализован strongest-positive/strongest-negative resolver.
- 2026-09-07: реализованы bounded FIFO action queue, depth/fingerprint guards, damage/status/material reactions и typed world-action events.
- 2026-09-07: существующие melee/projectile/periodic DamageRequest расширены damage type/buildup; Fireball и DoT definitions получили elemental types; actors и dummy подключены к runtime components.
