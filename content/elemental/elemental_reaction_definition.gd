## Immutable rule for damage+status, status+status or damage+material interaction.
extends Resource
class_name ElementalReactionDefinition

enum TriggerKind { DAMAGE_STATUS, STATUS_STATUS, DAMAGE_MATERIAL }

@export var id: StringName = &""
@export var trigger_kind: TriggerKind = TriggerKind.DAMAGE_STATUS
@export var first_id: StringName = &""
@export var second_id: StringName = &""
@export var priority: int = 0
@export var order_independent: bool = false
@export var actions: Array[ElementalReactionActionDefinition] = []


## Reports whether this definition matches the supplied typed trigger pair.
func matches(kind: TriggerKind, first: StringName, second: StringName) -> bool:
	if trigger_kind != kind:
		return false
	if first_id == first and second_id == second:
		return true
	return order_independent and first_id == second and second_id == first
