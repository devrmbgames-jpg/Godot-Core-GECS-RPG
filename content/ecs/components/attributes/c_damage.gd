## Базовый generic damage stat владельца. Конкретные abilities могут иметь свои multipliers.
extends AttributeComponent
class_name C_Damage


## Создаёт generic damage stat с default base damage 10.0.
func _init(initial_base_value: float = 10.0) -> void:
	super(initial_base_value)
