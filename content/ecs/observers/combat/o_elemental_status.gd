## Resolves direct status requests against accumulated state and status immunities.
extends Observer
class_name O_ElementalStatus

var _catalog: ElementalCatalog = PrototypeElementalCatalog.create()


## Listens only on subjects that own elemental runtime state.
func query() -> QueryBuilder:
	return q.with_all([C_ElementalState]).on_event(ElementalService.EVENT_STATUS_REQUESTED)


## Applies a typed direct-status request unless the target is dead.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var request := payload as ElementalStatusRequest
	if target == null or request == null or target.has_component(C_Dead):
		return
	ElementalResolver.apply_status(target, request, _catalog)
