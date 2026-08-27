# Items and Equipment Context

## Entry points

- `item_definition.gd` — immutable item design including optional `visual_scene` + semantic `rig_socket`.
- `granted_ability_definition.gd` — ability + slot grant.
- `item_factory.gd` — creates runtime off-tree item and inserts into inventory.
- `equipment_service.gd` / `equipment_request.gd` — typed equip boundary.
- `equipment_runtime.gd` — relations, stat modifiers, ability grants and presentation.
- `demo_item_catalog.gd` — Sword/Bow/Staff examples; Sword points to the prototype sword visual.

## Rule

Spatial pickup/station, runtime inventory Item и attached visual prop — разные identities. Demo stations создают inventory Entity через `ItemFactory`; `CharacterRig` отдельно инстанцирует `ItemDefinition.visual_scene` в semantic socket.
