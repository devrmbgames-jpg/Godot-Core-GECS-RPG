## Adapter над Area3D overlap set для interaction targeting.
##
## Здесь нет raycast/intersect_shape. Physics engine уже поддерживает список overlaps
## внутри Area3D; gameplay только фильтрует его по InteractionRules.
extends RefCounted
class_name InteractionTargeting


static func nearest_valid(actor: Entity, sensor: C_InteractionSensor) -> Entity:
	var area: Area3D = _resolve_area(actor, sensor)
	var actor_node: Node3D = actor as Node as Node3D
	if area == null or actor_node == null:
		return null
	var best: Entity
	var best_distance_squared: float = INF
	for body in area.get_overlapping_bodies():
		var target: Entity = _entity_from_node(body as Node)
		if not InteractionRules.is_valid(actor, target):
			continue
		var target_node: Node3D = target as Node as Node3D
		if target_node == null:
			continue
		var distance_squared: float = actor_node.global_position.distance_squared_to(target_node.global_position)
		if distance_squared < best_distance_squared:
			best = target
			best_distance_squared = distance_squared
	return best


static func contains_valid(actor: Entity, sensor: C_InteractionSensor, target: Entity) -> bool:
	if not InteractionRules.is_valid(actor, target):
		return false
	var area: Area3D = _resolve_area(actor, sensor)
	if area == null:
		return false
	for body in area.get_overlapping_bodies():
		if _entity_from_node(body as Node) == target:
			return true
	return false


static func _resolve_area(actor: Entity, sensor: C_InteractionSensor) -> Area3D:
	if actor == null or sensor == null:
		return null
	var actor_node: Node = actor as Node
	return actor_node.get_node_or_null(sensor.area_path) as Area3D if actor_node != null else null


static func _entity_from_node(node: Node) -> Entity:
	var current: Node = node
	while current != null:
		if current is Entity:
			return current as Entity
		current = current.get_parent()
	return null
