## Глобальный множитель стоимости маны abilities владельца. 1.0 — без изменения.
extends AttributeComponent
class_name C_ManaCostMultiplier


## Создаёт mana-cost multiplier; default 1.0 оставляет design cost неизменной.
func _init(initial_base_value: float = 1.0) -> void:
	super(initial_base_value)
