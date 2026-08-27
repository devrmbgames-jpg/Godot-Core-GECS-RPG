# Playground Context

`test.tscn` — main integration scene. Spatial actors/stations/crates расположены редактором; `test.gd` только связывает их и выдаёт runtime loadouts.

## Purpose

Playground должен демонстрировать production core API, но demo-only components/entities/observers остаются под `content/test`.

## Key utilities

- `entities/e_prototype_kinematic_character.tscn` — Player physics/ECS actor with `PrototypeCharacterRig` + prototype model.
- `demo_controller_switcher.gd` — transfers local controller between pre-placed actors and toggles enemies.
- `entities/e_demo_*_station.*` — interaction consumers for effects/items.
- `entities/e_demo_target_dummy.*` — static combat target.
- `observers/o_demo_*` — visual/demo responses.

## Visual integration exercised here

- Player starts with Demo Sword: equipment runtime attaches `prototype_sword.tscn` to the model's right-hand socket.
- Prototype attack animation drives the sword `TrailSword` through `anim_attack_started/finished`.
- Q/Fireball uses `prototype/fireball.tscn` during flight and `prototype/explotion.tscn` on first collision.

При добавлении механики в core желательно добавить минимальный example здесь, не внедряя demo dependency обратно в production directories.
