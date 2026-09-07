## Typed runtime resistance modifier with stable source identity for replace/remove operations.
extends RefCounted
class_name ElementalResistanceModifier

var damage_type: StringName = &""
var source_id: StringName = &""
var strength: int = 0


## Creates a signed modifier; resolution selects strongest negative and positive values.
func _init(
	initial_damage_type: StringName = &"",
	initial_source_id: StringName = &"",
	initial_strength: int = 0,
) -> void:
	damage_type = initial_damage_type
	source_id = initial_source_id
	strength = initial_strength
