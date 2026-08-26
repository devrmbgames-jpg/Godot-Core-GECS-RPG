## Relationship component: вклад source-object в stat владельца relationship.
##
## `Player --R_ModifiesStat(source=Sword, ADDED, 10)--> C_Damage`.
## Stable Script target избегает high-cardinality exact Entity pair archetypes GECS v8.
extends Component
class_name R_ModifiesStat

enum Operation { ADDED, INCREASED, MORE }

## Item/Effect/Passive, из-за которого modifier существует. Может быть null.
var modifier_source: Entity

## Operation хранится как int для безопасной передачи через generic Resource definitions.
@export var operation: int = Operation.ADDED

## ADDED: flat; INCREASED: доля; MORE: готовый multiplier.
@export var amount: float = 0.0


## Создаёт modifier relation payload; stat Script передаётся как relationship target отдельно.
func _init(initial_source: Entity = null, initial_operation: int = Operation.ADDED, initial_amount: float = 0.0) -> void:
	modifier_source = initial_source
	operation = initial_operation
	amount = initial_amount
