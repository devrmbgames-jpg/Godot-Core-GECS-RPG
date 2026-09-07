## Immutable direct status payload for an ability independent of health damage.
extends Resource
class_name ElementalStatusApplicationDefinition

@export var status_id: StringName = &""
@export_range(0.0, 100000.0, 0.1) var buildup_amount: float = 0.0


## Creates one typed direct-status design entry.
func _init(initial_status_id: StringName = &"", initial_buildup_amount: float = 0.0) -> void:
	status_id = initial_status_id
	buildup_amount = maxf(initial_buildup_amount, 0.0)
