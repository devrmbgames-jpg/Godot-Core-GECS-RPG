## One typed reaction action waiting in a bounded root-resolution queue.
extends RefCounted
class_name ElementalQueuedAction

var definition: ElementalReactionActionDefinition
var reaction_id: StringName = &""
var reaction_power: float = 0.0
var source: Entity
var ability: Entity
var hit_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO


## Creates an immutable queue record with provenance and spatial context.
func _init(
	initial_definition: ElementalReactionActionDefinition = null,
	initial_reaction_id: StringName = &"",
	initial_reaction_power: float = 0.0,
	initial_source: Entity = null,
	initial_ability: Entity = null,
	initial_hit_position: Vector3 = Vector3.ZERO,
	initial_direction: Vector3 = Vector3.ZERO,
) -> void:
	definition = initial_definition
	reaction_id = initial_reaction_id
	reaction_power = initial_reaction_power
	source = initial_source
	ability = initial_ability
	hit_position = initial_hit_position
	direction = initial_direction
