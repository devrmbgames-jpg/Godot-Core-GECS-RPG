## Typed reaction candidate paired with the available interaction power.
extends RefCounted
class_name ElementalReactionMatch

var reaction: ElementalReactionDefinition
var power: float = 0.0


## Creates one candidate before global priority sorting.
func _init(initial_reaction: ElementalReactionDefinition = null, initial_power: float = 0.0) -> void:
	reaction = initial_reaction
	power = initial_power
