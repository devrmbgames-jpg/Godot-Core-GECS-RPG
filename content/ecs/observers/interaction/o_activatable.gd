## Пример consumer interaction_activated: переключает C_Activatable state.
extends Observer
class_name O_Activatable


func query() -> QueryBuilder:
	return q.with_all([C_Activatable]).on_event(InteractionService.EVENT_ACTIVATED)


func each(_event: Variant, target: Entity, payload: Variant) -> void:
	var activatable := target.get_component(C_Activatable) as C_Activatable
	if activatable == null:
		return
	activatable.active = not activatable.active if activatable.toggle else true
	ECS.world.emit_event(InteractionService.EVENT_STATE_CHANGED, target, {"active": activatable.active, "request": payload})
