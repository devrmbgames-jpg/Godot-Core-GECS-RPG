## Единая validation-policy для interaction selection и activation.
extends RefCounted
class_name InteractionRules


static func is_valid(actor: Entity, target: Entity) -> bool:
	if actor == null or target == null or actor == target or not is_instance_valid(target):
		return false
	if target.has_component(C_Dead):
		return false
	var interactable: C_Interactable = target.get_component(C_Interactable) as C_Interactable
	if interactable == null or not interactable.enabled:
		return false
	var actor_node: Node3D = actor as Node as Node3D
	var target_node: Node3D = target as Node as Node3D
	if actor_node == null or target_node == null:
		return false
	var range_component: C_InteractionRange = actor.get_component(C_InteractionRange) as C_InteractionRange
	if range_component == null:
		return false
	var allowed_distance: float = maxf(range_component.value, 0.0)
	if interactable.max_distance > 0.0:
		allowed_distance = minf(allowed_distance, interactable.max_distance)
	return actor_node.global_position.distance_squared_to(target_node.global_position) <= allowed_distance * allowed_distance
