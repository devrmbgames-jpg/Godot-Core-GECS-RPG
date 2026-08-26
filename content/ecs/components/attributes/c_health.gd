## Текущее здоровье Entity.
##
## Maximum не хранится здесь: модифицируемый максимум является C_MaxHealth.
extends Component
class_name C_Health

@export var current: float = 100.0:
	set(new_value):
		var old_value := current
		current = new_value
		if not is_equal_approx(old_value, new_value):
			property_changed.emit(self, "current", old_value, new_value)


## Создаёт runtime current Health; clamp к C_MaxHealth выполняется отдельным observer/system boundary.
func _init(initial_current: float = 100.0) -> void:
	current = initial_current
