# Playground Context

`test.tscn` — main integration scene. Spatial actors/stations/crates расположены редактором; `test.gd` только связывает их и выдаёт runtime loadouts.

## Purpose

Playground должен демонстрировать production core API, но demo-only components/entities/observers остаются под `content/test`.

## Key utilities

- `demo_controller_switcher.gd` — transfers local controller between pre-placed actors and toggles enemies.
- `entities/e_demo_*_station.*` — interaction consumers for effects/items.
- `entities/e_demo_target_dummy.*` — static combat target.
- `observers/o_demo_*` — visual/demo responses.

При добавлении механики в core желательно добавить минимальный primitive example здесь, не внедряя demo dependency обратно в production directories.