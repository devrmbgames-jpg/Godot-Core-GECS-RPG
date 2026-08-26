## Множитель project gravity для CharacterBody3D. 1.0 — стандартная gravity Godot.
extends AttributeComponent
class_name C_Gravity


## Создаёт gravity multiplier stat; default 1.0 использует стандартную project gravity.
func _init(initial_base_value: float = 1.0) -> void:
	super(initial_base_value)
