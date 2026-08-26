## Целевая горизонтальная скорость locomotion в метрах в секунду.
extends AttributeComponent
class_name C_MoveSpeed


## Создаёт locomotion speed stat; default 5.0 соответствует 5 м/с target speed.
func _init(initial_base_value: float = 5.0) -> void:
	super(initial_base_value)
