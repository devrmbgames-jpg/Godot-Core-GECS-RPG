## Immutable equipment request payload.
extends RefCounted
class_name EquipmentRequest

var item: Entity


func _init(initial_item: Entity = null) -> void:
	item = initial_item
