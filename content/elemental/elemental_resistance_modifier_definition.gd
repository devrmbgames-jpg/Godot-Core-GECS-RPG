## Immutable resistance modifier contributed by an active status definition.
extends Resource
class_name ElementalResistanceModifierDefinition

@export var damage_type: StringName = &""
@export_range(-4, 4, 1) var strength: int = 0


## Creates a typed design-time modifier.
func _init(initial_damage_type: StringName = &"", initial_strength: int = 0) -> void:
	damage_type = initial_damage_type
	strength = initial_strength
