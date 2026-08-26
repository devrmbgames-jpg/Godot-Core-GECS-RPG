## Demo-only marker: какой ItemDefinition создаёт reusable equipment station.
extends Component
class_name C_DemoItemStation

@export var item_id: StringName = &"sword"


## Создаёт demo marker со stable item catalog id.
func _init(initial_item_id: StringName = &"sword") -> void:
	item_id = initial_item_id
