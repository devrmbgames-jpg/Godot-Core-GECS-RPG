## Stateless equip/unequip implementation shared by player, AI and scripted actions.
extends RefCounted
class_name EquipmentRuntime


static func equip(actor: Entity, item: Entity) -> void:
	if actor == null or item == null or not is_instance_valid(item):
		return
	var item_component := item.get_component(C_Item) as C_Item
	if item_component == null or item_component.definition == null:
		return
	var definition := item_component.definition
	var old := find_equipped(actor, definition.equipment_slot)
	if old != null and old != item:
		unequip(actor, old)
	if old == item:
		return
	actor.add_relationship(Relationship.new(R_Equipped.new(item, definition.equipment_slot), E_Item))
	for modifier_definition in definition.stat_modifiers:
		if modifier_definition == null or modifier_definition.stat_type == null:
			continue
		actor.add_relationship(
			Relationship.new(
				R_ModifiesStat.new(item, modifier_definition.operation, modifier_definition.amount),
				modifier_definition.stat_type,
			)
		)
	for grant in definition.granted_abilities:
		if grant != null and grant.ability != null:
			AbilityFactory.grant(actor, grant.ability, grant.slot, item)
	ECS.world.emit_event(
		&"presentation_action",
		actor,
		{"action": &"equip_item", "phase": &"equip", "item": item, "definition": definition},
	)


static func unequip(actor: Entity, item: Entity) -> void:
	if actor == null or item == null:
		return
	for relationship in actor.get_relationships(Relationship.new(R_Equipped.new(), E_Item)):
		var data := relationship.relation as R_Equipped
		if data != null and data.item == item:
			actor.remove_relationship(relationship, 1)
			break
	for relationship in actor.get_relationships(Relationship.new(R_ModifiesStat.new(), null)):
		var modifier := relationship.relation as R_ModifiesStat
		if modifier != null and modifier.modifier_source == item:
			actor.remove_relationship(relationship, 1)
	AbilityFactory.revoke_by_source(actor, item)
	var item_component := item.get_component(C_Item) as C_Item
	ECS.world.emit_event(
		&"presentation_action",
		actor,
		{"action": &"unequip_item", "phase": &"unequip", "item": item, "definition": item_component.definition if item_component != null else null},
	)


static func find_equipped(actor: Entity, slot: StringName) -> Entity:
	for relationship in actor.get_relationships(Relationship.new(R_Equipped.new(), E_Item)):
		var data := relationship.relation as R_Equipped
		if data != null and data.slot == slot and is_instance_valid(data.item):
			return data.item
	return null
