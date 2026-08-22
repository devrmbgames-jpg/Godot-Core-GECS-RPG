## Текущее здоровье Entity.
##
## Maximum не хранится здесь: модифицируемый максимум является C_MaxHealth.
extends Component
class_name C_Health

@export var current: float = 100.0


func _init(initial_current: float = 100.0) -> void:
	current = initial_current
