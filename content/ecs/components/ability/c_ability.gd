## Связывает runtime Ability Entity с immutable AbilityDefinition.
extends Component
class_name C_Ability

@export var definition: AbilityDefinition


## Создаёт runtime binding к immutable ability definition.
func _init(initial_definition: AbilityDefinition = null) -> void:
	definition = initial_definition
