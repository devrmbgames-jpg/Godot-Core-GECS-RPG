# Character Rig и Presentation Bridge

Gameplay systems не обращаются к `AnimationPlayer`, `AnimationTree`, skeleton sockets, audio или VFX напрямую. Они публикуют типизированный semantic event через `PresentationService`:

```text
PresentationActionEvent
  action = attack / cast_fireball / burning / equip_item / death
  phase = start / effect_applied / ...
  optional typed context = ability / item / item_definition / effect / target
```

`O_RigPresentation` принимает только `PresentationActionEvent`, находит `CharacterRig` actor и переводит semantic action в конкретную модель.

## CharacterRig

`CharacterRig` — обычный Godot Node3D adapter, **не ECS Component**. Это scene-tree glue, которое не участвует в ECS query.

Он умеет:

- инстанцировать готовую `model_scene`;
- найти/использовать AnimationTree или AnimationPlayer;
- переводить semantic action через `RigProfile.action_bindings`;
- обновлять locomotion blend;
- находить semantic sockets через `RigProfile.socket_bindings`;
- присоединять/отсоединять visual equipment через typed `RigEquipmentAttachment`.

Таким образом gameplay prefab персонажа не зависит от структуры конкретного FBX/GLTF rig.

## RigProfile

Profile хранит адаптацию конкретного animation set без Dictionary:

```text
Array[RigActionBinding]
  attack        -> Sword_Attack_01
  cast_fireball -> Cast_UpperBody
  death         -> Death_Back

Array[RigSocketBinding]
  main_hand -> NodePath(...)
  off_hand  -> NodePath(...)
  head      -> NodePath(...)
```

Также profile хранит путь state machine playback и locomotion blend property. Для другой модели меняется Resource/profile, а Ability/Effect systems остаются прежними.

## Locomotion

`S_RigLocomotion` читает actual Godot body velocity и resolved `C_MoveSpeed.value`, вычисляет нормализованный speed ratio и передаёт его rig. Здесь нет `C_Velocity`, поэтому источник истины физики не дублируется.

## Typed contract

Presentation layer следует общему правилу [STRICT_TYPING.md](STRICT_TYPING.md): project-owned semantic payload никогда не передаётся Dictionary'ем. Dictionary допустим только внутри adapter к внешнему API, если сам Godot/GECS навязывает такой return type.
