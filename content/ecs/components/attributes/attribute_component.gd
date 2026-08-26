## Базовый класс для модифицируемого числового атрибута.
##
## [member base_value] — исходное значение без временных modifiers.
## [member value] — закешированный итог, который читают hot-path systems.
extends Component
class_name AttributeComponent

## Базовое значение до применения R_ModifiesStat.
@export var base_value: float = 0.0

## Текущее resolved значение. Setter сообщает редкие rebuild-изменения Observers.
var value: float = 0.0:
	set(new_value):
		var old_value := value
		value = new_value
		if not is_equal_approx(old_value, new_value):
			property_changed.emit(self, "value", old_value, new_value)


## Инициализирует base и resolved cache одинаковым значением до первого stat rebuild.
func _init(initial_base_value: float = 0.0) -> void:
	base_value = initial_base_value
	value = initial_base_value


## Сбрасывает runtime cache к базовому значению.
func reset_to_base() -> void:
	value = base_value
