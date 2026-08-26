# ECS Components Context

Components — данные, не workflow.

## Groups

- `ability/` — ability queue, persistent casting, cooldown and grant ownership.
- `attributes/` — resolved stats, Health/Mana current values, dirty marker.
- `combat/` — team, combat state/target, projectile payload, death tag.
- `controller/` — player/AI/controller intent and AI goals.
- `core/` — generic ownership.
- `effect/` — effect runtime duration/tick/context.
- `input/` — device snapshot/profile owner.
- `interaction/` — interactable state, Area3D sensor state, optional drawing.
- `item/` — runtime inventory/item ref.
- `motion/` — controlled/external motion state.
- `physics/` — physical kind tags and gravity multiplier.
- `relationships/` — typed relation payloads.

## Rule

Если component начинает делать world queries, создавать Entities или публиковать orchestration events — логика, вероятно, должна перейти в System/Observer/helper.