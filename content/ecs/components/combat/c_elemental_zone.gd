## Runtime payload for one spatial elemental surface/cloud zone.
## Spatial overlap belongs to the Area3D Entity; this component owns only pulse/lifetime state.
extends Component
class_name C_ElementalZone

var definition: ElementalEnvironmentDefinition
var source: Entity
var ability: Entity
var remaining: float = 0.0
var tick_remaining: float = 0.0


## Creates pulse state from immutable environment design data. Zero duration means permanent.
func _init(initial_definition: ElementalEnvironmentDefinition = null, initial_source: Entity = null, initial_ability: Entity = null) -> void:
	definition = initial_definition
	source = initial_source
	ability = initial_ability
	if definition != null:
		remaining = maxf(0.0, definition.duration)
		tick_remaining = 0.0
