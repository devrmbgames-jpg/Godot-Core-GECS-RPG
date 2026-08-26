# ECS Observers Context

Observers — reactive boundary GECS events/relationship changes.

## Main routes

- `attributes/` — modifier relationship changes -> dirty stats; MaxHealth change -> clamp current Health.
- `combat/` — damage application, combat-state refresh after direct damage, death lifecycle.
- `effect/` — effect apply and heal events.
- `interaction/` — request validation and activatable state change.
- `item/` — equip/unequip request -> EquipmentRuntime.
- `presentation/` — semantic presentation event -> CharacterRig.

## Rule

Observer должен быть тонким: validate event, mutate bounded state или delegate to stateless runtime helper. Не превращать Observer в manager с собственным долговременным registry.