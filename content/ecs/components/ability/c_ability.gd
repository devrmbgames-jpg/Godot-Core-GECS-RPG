## Связывает runtime Ability Entity с immutable AbilityDefinition.
extends Component
class_name C_Ability

@export var definition: AbilityDefinition


func _init(initial_definition: AbilityDefinition = null) -> void:
	definition = initial_definition
