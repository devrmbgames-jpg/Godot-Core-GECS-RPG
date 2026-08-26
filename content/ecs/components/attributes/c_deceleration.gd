## Максимальная скорость изменения horizontal velocity при торможении без input.
extends AttributeComponent
class_name C_Deceleration


## Создаёт deceleration stat; default 30.0 задаёт rate остановки controlled motor.
func _init(initial_base_value: float = 30.0) -> void:
	super(initial_base_value)
