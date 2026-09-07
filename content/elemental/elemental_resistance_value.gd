## Typed runtime override for one target's base resistance level.
extends RefCounted
class_name ElementalResistanceValue

var damage_type: StringName = &""
var level: int = 0


## Creates a clamped base override.
func _init(initial_damage_type: StringName = &"", initial_level: int = 0) -> void:
	damage_type = initial_damage_type
	level = clampi(initial_level, -1, 4)
