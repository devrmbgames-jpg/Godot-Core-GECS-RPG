## Валидирует requested interaction и публикует semantic activation event.
extends Observer
class_name O_Interaction


func query() -> QueryBuilder:
	return q.with_all([C_Interactable]).on_event(InteractionService.EVENT_REQUESTED)


func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var request := payload as InteractionRequest
	if target == null or request == null or request.actor == null:
		return
	var interactable := target.get_component(C_Interactable) as C_Interactable
	if interactable == null or not interactable.enabled:
		return
	var actor_node := request.actor as Node as Node3D
	var target_node := target as Node as Node3D
	if actor_node == null or target_node == null:
		return
	var actor_range := request.actor.get_component(C_InteractionRange) as C_InteractionRange
	var allowed := actor_range.value if actor_range != null else 0.0
	if interactable.max_distance > 0.0:
		allowed = minf(allowed, interactable.max_distance)
	if actor_node.global_position.distance_to(target_node.global_position) > allowed:
		return
	ECS.world.emit_event(InteractionService.EVENT_ACTIVATED, target, request)
	PresentationService.publish(
		request.actor,
		PresentationActionEvent.for_target(interactable.presentation_action, &"interact", target),
	)
