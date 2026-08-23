# Primitive ARPG Playground

`res://content/test/test.tscn` — основная запускаемая сцена проекта. Все spatial объекты расставлены вручную в `.tscn`; `test.gd` не задаёт им позиции и не строит arena кодом.

## Управление

- `WASD` — движение.
- `Space` — primary ability текущего weapon.
- `F` — Shoot.
- `Q` — Fireball.
- `E` — Interaction.
- UI-кнопка **Switch Controller** — циклически передаёт локальный `C_InputPlayer + C_PlayerController` между `Player`, `RigidWarrior`, `RigidArcher`, `RigidMage`.

При переключении новый actor становится team `player`; остальные controllable AI actors становятся team `enemy`, получают обратно `C_AIController` и преследуют текущего игрока через `C_AIChase`. Поэтому один и тот же Input → ControllerIntent → Ability/Motion pipeline проверяется и на CharacterBody3D, и на RigidBody3D.

## Что находится на сцене

### Actors

- `Player` — CharacterBody3D motor.
- `RigidWarrior` — RigidBody3D force motor, Sword/Attack loadout.
- `RigidArcher` — RigidBody3D force motor, Bow/Shoot loadout.
- `RigidMage` — RigidBody3D force motor, Staff/Fireball loadout.
- `TargetDummy` — красный static combat target с Health, Armor и death lifecycle.

Каждый actor дополнительно имеет Shoot в `secondary` и Fireball в `skill_1`, поэтому delivery/cast/cooldown можно сравнивать независимо от текущего main-hand weapon.

### Motion / physics

Справа расположены `PushCrate`, ramp и два падающих RigidBody crate. Они проверяют, что CharacterBody external motion и RigidBody force motor не заменяют physics-world authority прямой записью искусственного `C_Velocity`.

### Interaction

Оранжевый `InteractionCube` использует обычные `C_Interactable + C_Activatable`. `E` переключает state, а demo presentation observer меняет размер/цвет cube. Gameplay Interaction system не знает об этом визуальном эффекте.

### Effects

Шесть заранее размещённых stations: Poison, Burning, Heal, Regeneration, Haste и Slow. `E` применяет выбранный `EffectDefinition` к текущему actor через тот же `EffectService`, который используют abilities. Haste/Slow проходят через `R_ModifiesStat`; Poison/Burning/Regen используют duration/tick pipeline.

### Items

Три reusable stations: Sword, Bow, Magic Staff. `E` создаёт runtime Item Entity через `ItemFactory`, кладёт его в `C_Inventory` и отправляет обычный `EquipmentService.equip`. Equipment затем создаёт stat-modifier relationships и выдаёт primary ability. Spatial station остаётся design-time Entity в сцене; runtime inventory item не является world-space object.

## Controller switching

`DemoControllerSwitcher` не создаёт actors. В Inspector/`.tscn` он хранит только NodePath списка уже размещённых candidates. При переключении он меняет controller components и обновляет `C_AIChase.target`. Это demo/debug utility, а не часть production gameplay core.

HUD показывает текущую Entity, Health, Mana, MoveSpeed, Damage, AttackSpeed и main-hand item — удобно сразу видеть эффект экипировки и buffs/debuffs.

## Rig

Primitive actors используют `PrimitiveCharacterRig`, который реализует тот же `CharacterRig` contract и визуализирует locomotion/action простым procedural bob/squash. Поэтому `presentation_action` заметен даже без art assets.

При подключении готовой модели `PrimitiveCharacterRig` заменяется обычным `CharacterRig` + `RigProfile` с AnimationTree/AnimationPlayer и semantic sockets. Ability/Effect/Equipment systems при этом не меняются.

## Проверка

Проект настроен запускать `content/test/test.tscn` как main scene. Полный smoke checklist остаётся в [TESTING.md](TESTING.md).
