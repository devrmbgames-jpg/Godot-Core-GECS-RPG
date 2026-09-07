## Immutable definition of one extensible damage type and its optional buildup mapping.
extends Resource
class_name ElementalDamageDefinition

@export var id: StringName = &""
@export var buildup_status_id: StringName = &""
@export_range(0.0, 100.0, 0.01) var buildup_per_damage: float = 0.0


## Creates a damage definition used by ElementalCatalog.
func _init(
	initial_id: StringName = &"",
	initial_status_id: StringName = &"",
	initial_buildup_per_damage: float = 0.0,
) -> void:
	id = initial_id
	buildup_status_id = initial_status_id
	buildup_per_damage = maxf(initial_buildup_per_damage, 0.0)
