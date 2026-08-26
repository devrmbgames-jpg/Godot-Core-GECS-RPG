## Actor relationship к стабильному E_Effect Script target.
## Конкретная effect instance хранится в relation data.
extends Component
class_name R_HasEffect

var effect: Entity
@export var effect_id: StringName = &""


## Создаёт effect relation payload; effect_id служит stable gameplay identity definition-а.
func _init(initial_effect: Entity = null, initial_effect_id: StringName = &"") -> void:
	effect = initial_effect
	effect_id = initial_effect_id
