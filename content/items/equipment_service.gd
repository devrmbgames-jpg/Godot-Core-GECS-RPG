## Stateless targeted equipment request API.
extends RefCounted
class_name EquipmentService

const EVENT_EQUIP: StringName = &"equip_requested"
const EVENT_UNEQUIP: StringName = &"unequip_requested"


## Публикует equip request на actor; actual relationship mutation выполняет O_Equipment/EquipmentRuntime.
static func equip(actor: Entity, item: Entity) -> void:
	if ECS.world != null and actor != null and item != null:
		ECS.world.emit_event(EVENT_EQUIP, actor, EquipmentRequest.new(item))


## Публикует unequip request на actor; runtime Item Entity остаётся в inventory.
static func unequip(actor: Entity, item: Entity) -> void:
	if ECS.world != null and actor != null and item != null:
		ECS.world.emit_event(EVENT_UNEQUIP, actor, EquipmentRequest.new(item))
