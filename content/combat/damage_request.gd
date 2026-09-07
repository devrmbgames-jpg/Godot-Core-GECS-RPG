## Immutable-by-convention payload of one instantaneous damage request.
## Existing positional constructor arguments remain compatible; optional elemental fields are appended.
extends RefCounted
class_name DamageRequest

enum Kind { DIRECT, PERIODIC }

var source: Entity
var ability: Entity
var amount: float = 0.0
var hit_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var kind: Kind = Kind.DIRECT
var damage_type: StringName = &"PHYSICAL"
var buildup_scale: float = 1.0
var status_applications: Array[ElementalStatusApplication] = []
var chain: ElementalChain
var reaction_depth: int = 0


## Creates a damage command snapshot. PERIODIC never refreshes combat linger.
## amount is nonnegative impact strength; negative resolved damage represents healing via affinity.
func _init(
	initial_source: Entity = null,
	initial_ability: Entity = null,
	initial_amount: float = 0.0,
	initial_hit_position: Vector3 = Vector3.ZERO,
	initial_direction: Vector3 = Vector3.ZERO,
	initial_kind: Kind = Kind.DIRECT,
	initial_damage_type: StringName = &"PHYSICAL",
	initial_buildup_scale: float = 1.0,
	initial_status_applications: Array[ElementalStatusApplication] = [],
) -> void:
	source = initial_source
	ability = initial_ability
	amount = initial_amount
	hit_position = initial_hit_position
	direction = initial_direction
	kind = initial_kind
	damage_type = initial_damage_type
	buildup_scale = initial_buildup_scale
	status_applications = initial_status_applications.duplicate()
