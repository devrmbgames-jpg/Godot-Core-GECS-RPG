# VFX Context

`content/vfx/` содержит visual-only эффекты и небольшие presentation helpers. VFX не владеет damage, targeting, collision или ability lifecycle.

## Entry points

- `prototype/fireball.tscn` — looping projectile visual для demo Fireball.
- `prototype/explotion.tscn` — one-shot impact visual; имя файла сохранено как в prototype asset.
- `prototype/trail_sword.tscn` — sword trail visual, вложенный в prototype sword prop.
- `vfx_spawner.gd` — canonical stateless helper для независимых world-space one-shot VFX после интеграции.

## Rules

- Projectile movement/collision остаются в `C_Projectile` + `S_Projectile`; VFX только следует за spatial Entity.
- Impact VFX создаётся отдельно от projectile Entity, иначе удаление projectile мгновенно уничтожит one-shot particles.
- Weapon trail принадлежит equipment visual/rig presentation, а не melee damage resolver.
- Gameplay code выбирает scenes через design/presentation data, а не по hardcoded ability ID.
- Новые VFX scripts документировать через `##` и обеспечивать явный lifecycle/cleanup.
