## Immutable payload targeted heal request.
extends RefCounted
class_name HealRequest

var source: Entity
var ability: Entity
var amount: float = 0.0


func _init(initial_source: Entity = null, initial_ability: Entity = null, initial_amount: float = 0.0) -> void:
	source = initial_source
	ability = initial_ability
	amount = initial_amount
