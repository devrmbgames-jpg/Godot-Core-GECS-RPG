## Resolves damage-channel impacts on cells, surfaces, zones and other entities without HP.
extends Observer
class_name O_ElementalEnvironment


## Selects targets with elemental state on the healthless-impact event.
func query() -> QueryBuilder:
	return q.with_all([C_ElementalState]).on_event(ElementalService.EVENT_ENVIRONMENT_IMPACT)


## Applies buildup and reactions without inventing health or duplicating the O_Damage authority.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var request := payload as DamageRequest
	if target == null or request == null or not is_instance_valid(target) or target.has_component(C_Health):
		return
	if request.reaction_depth > ElementalChain.MAX_DEPTH or not CombatRules.can_damage(request.source, target):
		return
	var state := target.get_component(C_ElementalState) as C_ElementalState
	var result := ElementalResolver.resolve_damage(state, ElementalService.catalog(), request)
	ElementalService.dispatch(target, result)
