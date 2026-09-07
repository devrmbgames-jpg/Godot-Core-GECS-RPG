## Typed before/after snapshot returned by status buildup and time updates.
extends RefCounted
class_name ElementalStatusTransition

var status_id: StringName = &""
var previous_buildup: float = 0.0
var current_buildup: float = 0.0
var activated: bool = false
var deactivated: bool = false


## Creates a transition without exposing mutable ElementalStatusState ownership.
func _init(
	initial_status_id: StringName = &"",
	initial_previous_buildup: float = 0.0,
	initial_current_buildup: float = 0.0,
	initial_activated: bool = false,
	initial_deactivated: bool = false,
) -> void:
	status_id = initial_status_id
	previous_buildup = initial_previous_buildup
	current_buildup = initial_current_buildup
	activated = initial_activated
	deactivated = initial_deactivated
