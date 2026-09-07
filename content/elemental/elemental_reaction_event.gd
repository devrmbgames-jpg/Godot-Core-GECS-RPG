## Typed notification that one reaction rule entered the bounded action queue.
extends RefCounted
class_name ElementalReactionEvent

var reaction_id: StringName = &""
var power: float = 0.0
var source: Entity
var ability: Entity


## Creates a reaction trace event for UI/VFX/debug observers.
func _init(
	initial_reaction_id: StringName = &"",
	initial_power: float = 0.0,
	initial_source: Entity = null,
	initial_ability: Entity = null,
) -> void:
	reaction_id = initial_reaction_id
	power = initial_power
	source = initial_source
	ability = initial_ability
