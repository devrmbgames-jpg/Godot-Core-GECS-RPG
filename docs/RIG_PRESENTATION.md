# Character Rig и Presentation Bridge

Gameplay systems не обращаются к `AnimationPlayer`, `AnimationTree`, skeleton sockets, audio или VFX напрямую. Они публикуют semantic event:

```text
presentation_action {
  action = attack / cast_fireball / burning / equip_item / death
  phase = start / effect_applied / ...
}
```

`O_RigPresentation` находит `CharacterRig` actor и переводит semantic action в конкретную модель.

## CharacterRig

`CharacterRig` — обычный Godot Node3D adapter, **не ECS Component**. Это scene-tree glue, которое не участвует в ECS query.

Он умеет:

- инстанцировать готовую `model_scene`;
- найти/использовать AnimationTree или AnimationPlayer;
- переводить semantic action через `RigProfile.action_map`;
- обновлять locomotion blend;
- находить semantic sockets;
- присоединять/отсоединять visual equipment.

Таким образом gameplay prefab персонажа не зависит от структуры конкретного FBX/GLTF rig.

## RigProfile

Profile хранит адаптацию конкретного animation set:

- `attack -> Sword_Attack_01`;
- `cast_fireball -> Cast_UpperBody`;
- `death -> Death_Back`;
- путь state machine playback;
- путь locomotion blend property;
- socket paths (`main_hand`, `off_hand`, `head`).

Для другой модели меняется Resource/profile, а Ability/Effect systems остаются прежними.

## Locomotion

`S_RigLocomotion` читает actual Godot body velocity и resolved `C_MoveSpeed.value`, вычисляет нормализованный speed ratio и передаёт его rig. Здесь нет `C_Velocity`, поэтому источник истины физики не дублируется.
