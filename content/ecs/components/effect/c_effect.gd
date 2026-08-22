## Связывает Effect Entity с immutable EffectDefinition.
extends Component
class_name C_Effect

@export var definition: EffectDefinition


func _init(initial_definition: EffectDefinition = null) -> void:
	definition = initial_definition
