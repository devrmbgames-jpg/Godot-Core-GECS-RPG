## Множитель скорости cast/windup. 1.0 — нормальная скорость.
extends AttributeComponent
class_name C_CastSpeed


## Создаёт cast-speed multiplier; default 1.0 означает normal logical work rate.
func _init(initial_base_value: float = 1.0) -> void:
	super(initial_base_value)
