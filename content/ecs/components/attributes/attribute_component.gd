## Базовый класс для модифицируемого числового атрибута.
##
## [member base_value] — исходное значение без временных modifiers.
## [member value] — закешированный итог, который читают hot-path systems.
## Наследники должны быть отдельными типами (`C_MoveSpeed`, `C_Armor` и т.д.),
## чтобы GECS мог фильтровать их обычными component queries.
extends Component
class_name AttributeComponent

## Базовое значение до применения R_ModifiesStat.
@export var base_value: float = 0.0

## Текущее resolved значение. Не изменяйте его вручную из gameplay systems;
## значение принадлежит StatResolver/S_StatRebuild.
var value: float = 0.0


func _init(initial_base_value: float = 0.0) -> void:
	base_value = initial_base_value
	value = initial_base_value


## Сбрасывает runtime cache к базовому значению.
func reset_to_base() -> void:
	value = base_value
