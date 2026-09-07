## Typed request for direct status buildup, reduction or clearing without HP damage.
extends RefCounted
class_name ElementalStatusRequest

enum Operation { ADD, REMOVE, CLEAR }

var status_id: StringName = &""
var amount: float = 0.0
var operation: Operation = Operation.ADD
var source: Entity
var ability: Entity
var hit_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var chain: ElementalChain
var reaction_depth: int = 0
## Explicit opt-in for beneficial self/allied status applications; never authorizes harmful HP damage.
var allow_friendly: bool = false


## Captures a status command; amount is gauge strength and is ignored for CLEAR.
func _init(initial_status: StringName = &"", initial_amount: float = 0.0, initial_source: Entity = null, initial_ability: Entity = null, initial_operation: Operation = Operation.ADD) -> void:
	status_id = initial_status
	amount = initial_amount
	source = initial_source
	ability = initial_ability
	operation = initial_operation
