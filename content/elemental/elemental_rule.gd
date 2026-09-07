## Immutable priority-ordered reaction rule. Status-pair matching is symmetric; action operands are explicit.
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


## Checks an impact or active status pair without changing runtime state.
func matches(trigger_id: StringName, incoming_id: StringName, state: C_ElementalState, catalog: ElementalCatalog) -> bool:
	if trigger != trigger_id:
		return false
	if required_tag != &"" and not state.has_tag(required_tag):
		return false
	if trigger == &"status":
		if not state.is_active(incoming, catalog):
			return false
		if required_status == &"":
			return true
		return state.is_active(required_status, catalog) and state.get_amount(required_status) >= minimum_gauge
	if incoming != &"" and incoming != incoming_id:
		return false
	if required_status != &"":
		return state.get_amount(required_status) > 0.0001 and state.get_amount(required_status) >= minimum_gauge
	return true
