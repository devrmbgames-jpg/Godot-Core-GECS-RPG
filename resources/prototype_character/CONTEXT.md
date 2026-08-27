# Prototype Character Context

`prototype_character.tscn` — визуальная humanoid model/state machine для проверки реального `CharacterRig` bridge вместо procedural primitive.

## Character contract

- Root script: `prototype_character.gd` / `PrototypeCharacterModel`.
- Semantic controls: `play_walk()`, `play_idle()`, `play_attack()`, `play_cast()`, `complete_cast()`, `play_cast_break()`.
- AnimationTree transitions читают root flags `has_walk`, `has_attack`, `has_cast`, `has_cast_completed`, `has_cast_break`.
- Attack animation emits `anim_attack_started` / `anim_attack_finished`; rig adapter использует их для sword trail.
- Right-hand equipment anchor: `slot_arm_right` -> `Hips/Spine/Tors/ArmR1/ArmR2/HandR/SlotR`.
- Left-hand anchor: `slot_arm_left` -> `Hips/Spine/Tors/ArmL2/ArmL2/HandL/SlotL`.

## Sword contract

- `prototype_sword.tscn` — visual prop, не Item Entity.
- Root script `prototype_sword.gd` / `PrototypeSword`.
- `set_enable_trail(bool)` только переключает child `TrailSword`.
- Runtime item definition должен ссылаться на sword scene через `ItemDefinition.visual_scene`; attachment выполняет rig presentation.

## Integration

Gameplay actor не заменяется этой scene целиком: CharacterBody3D/Entity остаётся physics/ECS authority, а `PrototypeCharacterRig` инстанцирует эту model scene как presentation child.
