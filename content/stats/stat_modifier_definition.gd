## Универсальное design-time описание stat modifier для Effects/Items/Passives.
extends Resource
class_name StatModifierDefinition

@export var stat_type: Script
@export var operation: int = R_ModifiesStat.Operation.ADDED
@export var amount: float = 0.0


## Создаёт immutable-style design modifier с stable stat Script target, operation и amount.
func _init(
	initial_stat_type: Script = null,
	initial_operation: int = R_ModifiesStat.Operation.ADDED,
	initial_amount: float = 0.0,
) -> void:
	stat_type = initial_stat_type
	operation = initial_operation
	amount = initial_amount
