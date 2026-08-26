# Items and Equipment Context

## Entry points

- `item_definition.gd` — immutable item design.
- `granted_ability_definition.gd` — ability + slot grant.
- `item_factory.gd` — creates runtime off-tree item and inserts into inventory.
- `equipment_service.gd` / `equipment_request.gd` — typed equip boundary.
- `equipment_runtime.gd` — relations, stat modifiers, ability grants and presentation.
- `demo_item_catalog.gd` — Sword/Bow/Staff examples.

## Rule

Spatial pickup/station и runtime inventory Item — разные identities. Demo stations создают inventory Entity через `ItemFactory`; inventory item не обязан быть Node3D.