# ARPG Integration Playground

`res://content/test/test.tscn` — основная запускаемая сцена проекта. Все spatial объекты расставлены вручную в `.tscn`; `test.gd` не задаёт им позиции и не строит arena кодом.

## Управление

- `WASD` — движение.
- Mouse — направление атаки/aim.
- `Space` — primary ability текущего weapon.
- `F` — Shoot.
- `Q` — Fireball.
- `E` — Interaction с единственной выбранной целью.
- **Switch Controller** — передаёт local controller между заранее размещёнными actors.
- **Enemies: ON/OFF** — временно выключает AI/combat participation остальных actors, не удаляя их со сцены.

## Interaction test

Каждый actor имеет child `InteractionSensor: Area3D` радиусом 2 м. `S_PlayerInteractionSelection` выбирает ближайший валидный `C_Interactable`; никакого постоянного interaction raycast нет. HUD показывает `Interact target`.

`InteractionCube`, effect stations и item stations имеют optional `C_InterractDrawing`, поэтому ближайшая выбранная цель подсвечивается. Удаление этого компонента демонстрирует, что drawing не является условием самой interaction.

AI использует отдельный `C_AIInteractionGoal`: это placeholder для будущего BT/Utility AI/GOAP, где behavior сначала решает, **какой** рычаг/кнопка ему нужна, и только затем generic Area3D integration проверяет доступность.

## Combat test

Actors также имеют `CombatSensor: Area3D` радиусом 8 м. Nearby enemy удерживает `C_CombatState`; offensive ability и direct damage запускают/продлевают linger timer. В HUD видны `Combat ON/OFF` и количество nearby enemies.

В combat state персонаж постоянно смотрит на mouse cursor, поэтому `WASD` превращается в forward/strafe/backpedal относительно aim. Backpedal медленнее. Вне combat state actor снова поворачивается по направлению движения, но в момент Attack/Shoot/Fireball всё равно разворачивается к cursor.

## Что находится на сцене

- `Player` — CharacterBody3D/ECS actor с `PrototypeCharacterRig` и `prototype_character.tscn` как visual model.
- `RigidWarrior` — RigidBody3D, Sword/Attack.
- `RigidArcher` — RigidBody3D, Bow/Shoot.
- `RigidMage` — RigidBody3D, Staff/Fireball.
- `TargetDummy` — Health/Armor/death test.
- `InteractionCube` — generic activatable.
- 6 effect stations: Poison, Burning, Heal, Regeneration, Haste, Slow.
- 3 equipment stations: Sword, Bow, Magic Staff.
- PushCrate, ramp и падающие RigidBody crates для physics interaction.

Все spatial nodes уже стоят в `test.tscn` и редактируются через Godot editor.

## Prototype rig, sword и VFX

Player стартует с Demo Sword. `EquipmentRuntime` публикует typed equipment presentation event, а `PrototypeCharacterRig` разрешает semantic socket `main_hand` в правую руку prototype model. Поэтому `prototype_sword.tscn` действительно появляется в руке; при экипировке Bow/Staff socket очищается, при повторной экипировке Sword visual возвращается.

Attack использует animation method-track signals `anim_attack_started/finished`: только presentation adapter включает и выключает `TrailSword`. Melee damage resolver о trail ничего не знает.

Fireball использует два prototype VFX из `AbilityDefinition`:

- `projectile_visual_scene = fireball.tscn` — child projectile на время полёта;
- `impact_vfx_scene = explotion.tscn` — независимый world-space one-shot на первом collision.

Projectile movement/collision остаются authority `C_Projectile + S_Projectile`; VFX не участвуют в damage/effect rules.

Primitive RigidBody actors продолжают использовать `PrimitiveCharacterRig` как fallback и позволяют сравнить оба presentation adapters в одной сцене.
