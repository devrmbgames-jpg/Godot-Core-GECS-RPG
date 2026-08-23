## Stateless factory/lifecycle helper для inventory Item Entity.
extends RefCounted
class_name ItemFactory


static func give(actor: Entity, definition: ItemDefinition) -> Entity:
	if ECS.world == null or actor == null or definition == null:
		return null
	var inventory := actor.get_component(C_Inventory) as C_Inventory
	if inventory == null:
		actor.add_component(C_Inventory.new())
		inventory = actor.get_component(C_Inventory) as C_Inventory
	var item := E_Item.new()
	item.name = "Item_%s" % String(definition.id)
	item.add_component(C_Item.new(definition))
	item.add_component(C_EntityOwner.new(actor))
	ECS.world.add_entity(item, null, false)
	inventory.add(item)
	return item
