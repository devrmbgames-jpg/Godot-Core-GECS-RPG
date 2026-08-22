## Design-time описание одного stat modifier внутри EffectDefinition.
extends Resource
class_name EffectStatModifier

@export var stat_type: Script
@export var operation: R_ModifiesStat.Operation = R_ModifiesStat.Operation.ADDED
@export var amount: float = 0.0


func _init(
	initial_stat_type: Script = null,
	initial_operation: R_ModifiesStat.Operation = R_ModifiesStat.Operation.ADDED,
	initial_amount: float = 0.0,
) -> void:
	stat_type = initial_stat_type
	operation = initial_operation
	amount = initial_amount
