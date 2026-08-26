## Валидирует requested interaction и публикует semantic activation event.
extends Observer
class_name O_Interaction


func query() -> QueryBuilder:
	return q.with_all([C_Interactable]).on_event(InteractionService.EVENT_REQUESTED)


func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var request: InteractionRequest = payload as InteractionRequest
	if target == null or request == null or request.actor == null:
		return
	if not InteractionRules.is_valid(request.actor, target):
		return
	var interactable: C_Interactable = target.get_component(C_Interactable) as C_Interactable
	ECS.world.emit_event(InteractionService.EVENT_ACTIVATED, target, request)
	PresentationService.publish(
		request.actor,
		PresentationActionEvent.for_target(
			interactable.presentation_action,
			&"interact",
			target,
		),
	)
