## Скорость плавного поворота персонажа в радианах в секунду.
extends AttributeComponent
class_name C_TurnSpeed


## Создаёт turn-speed stat; значение измеряется в радианах в секунду.
func _init(initial_base_value: float = 10.0) -> void:
	super(initial_base_value)
