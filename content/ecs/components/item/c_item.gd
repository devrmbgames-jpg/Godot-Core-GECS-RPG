## Связывает runtime Item Entity с immutable ItemDefinition.
extends Component
class_name C_Item

@export var definition: ItemDefinition


## Создаёт runtime binding к immutable item definition.
func _init(initial_definition: ItemDefinition = null) -> void:
	definition = initial_definition
