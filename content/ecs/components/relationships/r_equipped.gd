## Actor -> stable E_Item Script equipment relationship.
## Конкретная item instance хранится в relation data.
extends Component
class_name R_Equipped

var item: Entity
@export var slot: StringName = &""


func _init(initial_item: Entity = null, initial_slot: StringName = &"") -> void:
	item = initial_item
	slot = initial_slot
