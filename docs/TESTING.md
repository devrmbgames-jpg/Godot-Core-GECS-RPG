# Testing и smoke checklist

## Validation status

Код и API проаудированы против **зафиксированного GECS v8 submodule** (`14d4282e...`, release-v8.0.0): используемые `CommandBuffer`, Observer custom events, relationships и `World.add_entity(..., add_to_tree)` существуют в этой версии.

Runtime Godot execution не является заменой source audit: перед merge ветку необходимо открыть в Godot 4.7 и пройти checklist ниже. На текущем этапе автоматический GdUnit/CI suite в проекте отсутствует.

## Demo controls

- `WASD` — movement.
- `Space` — primary ability.
- `F` — secondary ability.
- `Q` — skill 1.
- `E` — interaction.

Bindings находятся в Godot InputMap и могут быть изменены через `InputBindingService`.

## Smoke checklist

1. Открыть `content/test/test.tscn`, убедиться, что scripts импортируются без parse errors.
2. Player плавно разгоняется/тормозит и поворачивается по направлению движения.
3. Falling RigidBody crate не приводит к мгновенному обнулению внешнего движения CharacterBody.
4. Enemy RigidBody преследует Player через force-based motor и атакует в радиусе.
5. `Space/F/Q` проходят Ability queue; Fireball тратит mana, создаёт projectile и Burning.
6. Haste/Slow через `EffectService` меняют resolved stats и возвращают их после expiry.
7. Sword/Bow/Staff можно передавать в `EquipmentService.equip`; старый main-hand снимается, modifiers/abilities обновляются.
8. Interaction cube переключает `C_Activatable.active` через `E`.
9. При Health <= 0 добавляется `C_Dead`, AI/cast останавливаются, публикуется `actor_died`.
10. Подключить реальную модель в `CharacterRig.model_scene` + `RigProfile`; semantic actions не должны требовать изменений Ability code.

## Profiling targets

Перед масштабированием проверить:

- количество archetypes при сотнях actors/items/effects;
- churn Effect/Projectile Entity;
- время `S_StatRebuild` при массовом equip/aura update;
- `S_RigLocomotion` и physics cost;
- количество одновременно активных cooldown/effects.

Если profiling показывает high-cardinality relationship explosion, конкретную runtime reference следует оставить в component/relation data, а relationship target сделать стабильным Script/type — это уже базовое правило данного ядра.
