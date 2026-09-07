## Immutable accumulation, activation, duration and decay rules for one status ID.
extends Resource
class_name ElementalStatusDefinition

@export var id: StringName = &""
@export_range(0.001, 100000.0, 0.1) var activation_threshold: float = 1.0
@export_range(0.0, 100000.0, 0.1) var deactivation_threshold: float = 0.0
@export_range(0.001, 100000.0, 0.1) var max_buildup: float = 100.0
@export_range(0.0, 3600.0, 0.1) var duration: float = 0.0
@export_range(0.0, 100000.0, 0.1) var decay_per_second: float = 0.0
@export var resistance_modifiers: Array[ElementalResistanceModifierDefinition] = []


## Creates normalized status design data; catalog validation reports invalid threshold ordering.
func _init(
	initial_id: StringName = &"",
	initial_activation_threshold: float = 1.0,
	initial_deactivation_threshold: float = 0.0,
	initial_max_buildup: float = 100.0,
	initial_duration: float = 0.0,
	initial_decay_per_second: float = 0.0,
) -> void:
	id = initial_id
	activation_threshold = maxf(initial_activation_threshold, 0.001)
	deactivation_threshold = maxf(initial_deactivation_threshold, 0.0)
	max_buildup = maxf(initial_max_buildup, activation_threshold)
	duration = maxf(initial_duration, 0.0)
	decay_per_second = maxf(initial_decay_per_second, 0.0)
