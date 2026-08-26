## Immutable payload одного мгновенного damage request.
extends RefCounted
class_name DamageRequest

enum Kind { DIRECT, PERIODIC }

var source: Entity
var ability: Entity
var amount: float = 0.0
var hit_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var kind: Kind = Kind.DIRECT


## Создаёт damage command snapshot. Kind.DIRECT может удерживать combat state,
## тогда как Kind.PERIODIC предназначен для DoT и не должен обновлять combat linger.
func _init(
	initial_source: Entity = null,
	initial_ability: Entity = null,
	initial_amount: float = 0.0,
	initial_hit_position: Vector3 = Vector3.ZERO,
	initial_direction: Vector3 = Vector3.ZERO,
	initial_kind: Kind = Kind.DIRECT,
) -> void:
	source = initial_source
	ability = initial_ability
	amount = initial_amount
	hit_position = initial_hit_position
	direction = initial_direction
	kind = initial_kind
