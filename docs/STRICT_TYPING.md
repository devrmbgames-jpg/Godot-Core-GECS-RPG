# Strict typing и границы Dictionary

Gameplay-код ядра использует классы как контракты между systems, observers и services. Семантические данные не передаются как `Dictionary` со строковыми ключами.

## Правило

Если набор полей имеет имя и смысл в gameplay, он получает отдельный тип:

```gdscript
DamageAppliedEvent.new(request, applied, health.current)
PresentationActionEvent.for_ability(action, &"start", ability)
InteractionStateChangedEvent.new(active, request)
```

Это относится к:

- GECS custom-event payloads;
- request/result objects;
- physics results, которые используются gameplay-кодом;
- editor-facing mappings/configuration;
- runtime records с фиксированной схемой.

Runtime payload обычно наследуется от `RefCounted`. Design/editor configuration — от `Resource`.

## Physics boundary

`PhysicsDirectSpaceState3D.intersect_ray()` по API Godot возвращает `Dictionary`. Полностью убрать его нельзя. Поэтому `CombatQuery` является adapter boundary: он читает engine Dictionary локально и сразу создаёт `CombatHit`.

За пределами `CombatQuery` запрещены:

```gdscript
hit.get("entity")
hit.get("position")
```

Используется:

```gdscript
var hit: CombatHit = CombatQuery.raycast_entity(...)
if hit != null and hit.entity != null:
    DamageService.request(..., hit.position, ...)
```

## Presentation

Все semantic presentation events проходят через:

```text
PresentationService
        ↓
PresentationActionEvent
        ↓
O_RigPresentation
        ↓
CharacterRig
```

Ability, Effect, Equipment и Interaction не создают произвольные payload dictionaries.

## RigProfile

`RigProfile.action_map` и `socket_paths` заменены на typed arrays:

```text
Array[RigActionBinding]
Array[RigSocketBinding]
```

Runtime equipment attachment также представлен `RigEquipmentAttachment`, а не Dictionary lookup.

## Допустимые исключения

Dictionary остаётся допустим внутри внешнего/инфраструктурного API, когда тип задаётся не нашим проектом: например сырой результат `intersect_ray()` или внутренние структуры GECS (`Entity.components`). Такой Dictionary должен быть локализован внутри adapter/helper и не становиться gameplay contract.
