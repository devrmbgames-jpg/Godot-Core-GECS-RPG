## Relationship component, описывающий вклад source Entity в stat target Entity.
##
## Пример: `Sword --R_ModifiesStat(C_Damage, ADDED, 10)--> Player`.
## Relation считается immutable после добавления: изменение modifier оформляется
## удалением старой relationship и добавлением новой, чтобы dirty Observer получил событие.
extends Component
class_name R_ModifiesStat

enum Operation {
	ADDED,
	INCREASED,
	MORE,
}

## Script конкретного AttributeComponent, например C_Damage или C_MoveSpeed.
@export var stat_type: Script

## Как [member amount] участвует в формуле.
@export var operation: Operation = Operation.ADDED

## ADDED: плоское значение; INCREASED: доля (0.20 = +20%);
## MORE: готовый multiplier (1.20 = 20% more, 0.80 = 20% less).
@export var amount: float = 0.0


func _init(
	initial_stat_type: Script = null,
	initial_operation: Operation = Operation.ADDED,
	initial_amount: float = 0.0,
) -> void:
	stat_type = initial_stat_type
	operation = initial_operation
	amount = initial_amount
