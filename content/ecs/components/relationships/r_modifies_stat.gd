## Relationship component, описывающий вклад некоторого source-object в stat владельца.
##
## Relationship хранится на actor, а target — Script нужного stat:
## `Player --R_ModifiesStat(source=Sword, ADDED, 10)--> C_Damage`.
## Это избегает высококардинальных exact Entity targets в GECS v8 archetypes.
## Relation считается immutable после добавления.
extends Component
class_name R_ModifiesStat

enum Operation {
	ADDED,
	INCREASED,
	MORE,
}

## Entity, из-за которой modifier существует: item/effect/passive. Может быть null
## для системных modifiers. Это metadata relation, а не GECS relationship target.
var modifier_source: Entity

## Как [member amount] участвует в формуле.
@export var operation: Operation = Operation.ADDED

## ADDED: плоское значение; INCREASED: доля (0.20 = +20%);
## MORE: готовый multiplier (1.20 = 20% more, 0.80 = 20% less).
@export var amount: float = 0.0


func _init(
	initial_source: Entity = null,
	initial_operation: Operation = Operation.ADDED,
	initial_amount: float = 0.0,
) -> void:
	modifier_source = initial_source
	operation = initial_operation
	amount = initial_amount
