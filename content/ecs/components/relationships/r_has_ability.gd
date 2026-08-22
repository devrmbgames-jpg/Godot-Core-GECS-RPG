## Actor -> AbilityInstance relationship.
##
## Здесь хранится только состояние владения/размещения ability. Cooldown, charges
## и другие сложные runtime данные должны жить на Ability Entity components.
extends Component
class_name R_HasAbility

## Семантический слот (`primary`, `secondary`, `skill_1`), не физическая клавиша.
@export var slot: StringName = &""


func _init(initial_slot: StringName = &"") -> void:
	slot = initial_slot
