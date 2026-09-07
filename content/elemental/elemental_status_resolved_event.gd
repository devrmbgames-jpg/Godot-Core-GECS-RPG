## Typed result of one direct or reaction-driven status application.
extends RefCounted
class_name ElementalStatusResolvedEvent

var request: ElementalStatusRequest
var transition: ElementalStatusTransition
var ignored_by_immunity: bool = false
var triggered_reactions: Array[StringName] = []


## Creates a resolved status snapshot for observers/UI/presentation.
func _init(
	initial_request: ElementalStatusRequest = null,
	initial_transition: ElementalStatusTransition = null,
	initial_ignored_by_immunity: bool = false,
) -> void:
	request = initial_request
	transition = initial_transition
	ignored_by_immunity = initial_ignored_by_immunity
