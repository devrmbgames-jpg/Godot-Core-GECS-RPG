## Множитель скорости attack timeline. 1.0 — нормальная скорость.
extends AttributeComponent
class_name C_AttackSpeed


## Создаёт attack-speed multiplier; default 1.0 сохраняет design cast work без ускорения.
func _init(initial_base_value: float = 1.0) -> void:
	super(initial_base_value)
