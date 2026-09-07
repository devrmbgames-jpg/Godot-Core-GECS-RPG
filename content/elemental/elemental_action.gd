## Immutable instruction interpreted by ElementalResolver or the world action adapter.
extends Resource
class_name ElementalAction

enum Kind { EXCHANGE, ADD_GAUGE, REMOVE_GAUGE, DAMAGE, APPLY_EFFECT, SPAWN, TRANSFORM, ADD_TAG, REMOVE_TAG }

@export var kind: Kind = Kind.ADD_GAUGE
@export var status_id: StringName = &""
@export var other_status: StringName = &""
@export var output_status: StringName = &""
@export var damage_type: StringName = &"PHYSICAL"
@export var entity_id: StringName = &""
@export var material_id: StringName = &""
@export var tag: StringName = &""
@export var amount: float = 0.0
@export var scale: float = 0.0
@export var minimum: float = 0.0
@export var output_scale: float = 1.0
@export var use_impact: bool = false
@export var output_on_exhausted: bool = false
@export var require_exhausted: bool = false
@export var allow_buildup: bool = false
@export var effect: EffectDefinition


## Returns the action magnitude from fixed strength and the current reaction strength.
func magnitude(strength: float) -> float:
	return maxf(0.0, amount + scale * strength)
