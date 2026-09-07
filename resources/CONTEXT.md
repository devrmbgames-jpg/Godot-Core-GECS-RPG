# Resources Context

`resources/` содержит reusable prototype/imported content, которое подключается к runtime core через adapters и design Resources.

## Directories

- `prototype_character/` — prototype humanoid rig/state machine и sword prop.

## Boundary

Эти scenes могут иметь animation/presentation scripts, но не должны владеть ECS gameplay state. Actor physics остаётся на gameplay Entity, equipment ownership — в item/equipment runtime, а abilities/damage — в соответствующих core subsystems.
