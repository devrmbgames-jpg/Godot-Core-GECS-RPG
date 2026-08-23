## Demo-only marker: какой стандартный Effect выдаёт interaction station.
extends Component
class_name C_DemoEffectStation

@export var effect_id: StringName = &"poison"


func _init(initial_effect_id: StringName = &"poison") -> void:
	effect_id = initial_effect_id
