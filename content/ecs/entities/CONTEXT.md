# ECS Entities Context

Entity types используются только когда объект имеет собственную identity/lifecycle.

- `character/e_kinematic_character.*` — CharacterBody3D actor baseline.
- `character/e_rigid_character.*` — RigidBody3D actor baseline.
- `combat/e_projectile.*` — spatial projectile Entity.
- `ability/e_ability.gd` — off-tree runtime ability identity.
- `effect/e_effect.gd` — off-tree runtime effect identity.
- `item/e_item.gd` — off-tree runtime inventory item identity.
- `interaction/e_activatable.*` — world-space interactable prototype.

Не создавать Entity для мгновенного request/event без независимого lifecycle.