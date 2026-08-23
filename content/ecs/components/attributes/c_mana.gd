## Текущий запас маны Entity. Максимум хранится отдельно в C_MaxMana.
extends Component
class_name C_Mana

@export var current: float = 100.0


func _init(initial_current: float = 100.0) -> void:
	current = initial_current
