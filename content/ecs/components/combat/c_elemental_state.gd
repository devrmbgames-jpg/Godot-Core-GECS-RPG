## Runtime accumulated statuses for any actor, cell, zone, cloud, surface or projectile.
extends Component
class_name C_ElementalState

var statuses: Array[ElementalStatusState] = []


## Returns runtime state by open status ID or null when no buildup exists.
func get_status(status_id: StringName) -> ElementalStatusState:
	for status in statuses:
		if status.definition != null and status.definition.id == status_id:
			return status
	return null


## Returns a stable snapshot of currently active status IDs.
func get_active_status_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for status in statuses:
		if status.active and status.definition != null:
			result.append(status.definition.id)
	result.sort()
	return result


## Applies signed buildup using the supplied definition and creates runtime state lazily.
func apply_status(
	definition: ElementalStatusDefinition,
	amount: float,
	source: Entity = null,
	ability: Entity = null,
) -> ElementalStatusTransition:
	if definition == null:
		return ElementalStatusTransition.new()
	var state := get_status(definition.id)
	if state == null:
		state = ElementalStatusState.new(definition)
		statuses.append(state)
	return state.apply_delta(amount, source, ability)


## Clears both active state and latent buildup for one status ID.
func remove_status(status_id: StringName) -> ElementalStatusTransition:
	var state := get_status(status_id)
	if state == null or state.definition == null:
		return ElementalStatusTransition.new(status_id)
	return state.apply_delta(-state.buildup)


## Advances all status clocks and removes empty inactive runtime records.
func advance(delta: float) -> Array[ElementalStatusTransition]:
	var transitions: Array[ElementalStatusTransition] = []
	for status in statuses:
		var transition := status.advance(delta)
		if transition.previous_buildup != transition.current_buildup or transition.deactivated:
			transitions.append(transition)
	for index in range(statuses.size() - 1, -1, -1):
		if not statuses[index].active and is_zero_approx(statuses[index].buildup):
			statuses.remove_at(index)
	return transitions
