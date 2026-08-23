## Actor relationship к низкокардинальному E_Ability Script target.
##
## Конкретная runtime instance хранится в relation data, чтобы unique ability Entity
## не становилась exact-target частью archetype signature GECS v8.
extends Component
class_name R_HasAbility

var ability: Entity

## Семантический слот (`primary`, `secondary`, `skill_1`), не физическая клавиша.
@export var slot: StringName = &""


func _init(initial_ability: Entity = null, initial_slot: StringName = &"") -> void:
	ability = initial_ability
	slot = initial_slot
