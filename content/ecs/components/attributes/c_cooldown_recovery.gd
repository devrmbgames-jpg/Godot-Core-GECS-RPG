## Скорость течения ability cooldown. 1.0 — одна cooldown-секунда за реальную секунду.
extends AttributeComponent
class_name C_CooldownRecovery


## Создаёт cooldown-recovery multiplier с normal rate 1.0.
func _init(initial_base_value: float = 1.0) -> void:
	super(initial_base_value)
