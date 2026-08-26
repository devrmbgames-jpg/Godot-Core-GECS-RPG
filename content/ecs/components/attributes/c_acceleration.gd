## Максимальная скорость изменения horizontal velocity при разгоне.
extends AttributeComponent
class_name C_Acceleration


## Создаёт acceleration stat; default 25.0 означает единиц horizontal velocity в секунду.
func _init(initial_base_value: float = 25.0) -> void:
	super(initial_base_value)
