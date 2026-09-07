## Immutable, priority-ordered reaction rule. Triggers are damage, status or material.
extends Resource
class_name ElementalRule

@export var id: StringName = &""
@export var trigger: StringName = &"damage"
@export var incoming: StringName = &""
@export var required_status: StringName = &""
@export var required_tag: StringName = &""
@export var minimum_gauge: float = 0.0
@export var priority: int = 0
@export var actions: Array[ElementalAction] = []


## Matches an impact or a status-pair candidate without changing runtime state.
func matches(trigger_id: StringName, incoming_id: StringName, state: C_ElementalState, catalog: ElementalCatalog) -> bool:
	if trigger != trigger_id or (incoming != &"" and incoming != incoming_id):
		return false
	if required_tag != &"" and not state.has_tag(required_tag):
		return false
	if required_status != &"":
		if trigger == &"status":
			return state.is_active(required_status, catalog)
		return state.get_amount(required_status) > 0.0001
	return true
