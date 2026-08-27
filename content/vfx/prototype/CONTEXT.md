# Prototype VFX Context

Эта папка — набор временных box/particle VFX для ручной проверки presentation integration.

## Assets

- `fireball.tscn` — persistent visual, ожидается как child projectile на время полёта.
- `explotion.tscn` + `explotion.gd` — one-shot impact; script запускает particles и освобождает root после завершения.
- `trail_sword.tscn` — child prototype sword; visibility переключает `PrototypeSword.set_enable_trail()`.

Не переносить damage/effect logic в эти scenes. Их можно заменить art assets без изменения gameplay contracts.
