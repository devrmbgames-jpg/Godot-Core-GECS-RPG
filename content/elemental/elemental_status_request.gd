## Immutable direct-status request for abilities and scripted environment effects.
extends RefCounted
class_name ElementalStatusRequest

var source: Entity
var ability: Entity
var status_id: StringName = &""
var buildup_amount: float = 0.0
var context: ElementalResolutionContext
var hit_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO


## Creates a status request that may share a root reaction context.
func _init(
	initial_source: Entity = null,
	initial_ability: Entity = null,
	initial_status_id: StringName = &"",
	initial_buildup_amount: float = 0.0,
	initial_context: ElementalResolutionContext = null,
	initial_hit_position: Vector3 = Vector3.ZERO,
	initial_direction: Vector3 = Vector3.ZERO,
) -> void:
	source = initial_source
	ability = initial_ability
	status_id = initial_status_id
	buildup_amount = initial_buildup_amount
	context = initial_context
	hit_position = initial_hit_position
	direction = initial_direction
