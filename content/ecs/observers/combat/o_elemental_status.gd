## Applies direct status requests to ECS-authoritative gauges without requiring a health component.
extends Observer
class_name O_ElementalStatus


## Selects elemental targets for typed status commands.
func query() -> QueryBuilder:
	return q.with_all([C_ElementalState]).on_event(ElementalService.EVENT_STATUS_REQUESTED)


## Enforces team policy before mutation, then resolves reactions and dispatches their side effects.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var request := payload as ElementalStatusRequest
	if target == null or request == null or not is_instance_valid(target):
		return
	if request.reaction_depth > ElementalChain.MAX_DEPTH or target.has_component(C_Dead):
		return
	var permitted := CombatRules.can_damage(request.source, target)
	if request.allow_friendly and CombatRules.can_heal(request.source, target):
		permitted = true
	if request.operation != ElementalStatusRequest.Operation.ADD and request.source == null:
		permitted = true
	if not permitted:
		return
	var state := target.get_component(C_ElementalState) as C_ElementalState
	var result := ElementalResolver.resolve_status(state, ElementalService.catalog(), request)
	ElementalService.dispatch(target, result)
