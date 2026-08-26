## Immutable equipment request payload.
extends RefCounted
class_name EquipmentRequest

var item: Entity


## Создаёт request на конкретную runtime Item Entity.
func _init(initial_item: Entity = null) -> void:
	item = initial_item
