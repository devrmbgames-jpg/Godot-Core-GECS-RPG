# Documentation Context

Архитектурные документы предназначены и для разработчиков, и для AI indexing.

- `README.md` — общий индекс.
- `ARCHITECTURE.md` — authority/cardinality/data placement.
- `STRICT_TYPING.md` — typed boundaries и допустимые Dictionary adapters.
- `ATTRIBUTES.md` — stat formula/dirty rebuild.
- `ABILITIES_RELATIONSHIPS.md`, `COMBAT_ABILITIES.md` — abilities/combat.
- `CONTROLLERS_INTERACTION.md`, `MOTION_CONTROLLERS_INPUT.md` — control/motion/interaction.
- `EFFECTS.md`, `ITEMS_EQUIPMENT.md` — feature docs.
- `RIG_PRESENTATION.md` — presentation adapter.
- `PLAYGROUND.md`, `TESTING.md` — manual integration verification.

При изменении публичного contract обновлять doc comment в `.gd` и связанный документ. `CONTEXT.md` обновлять, когда меняются canonical entry points или routing.