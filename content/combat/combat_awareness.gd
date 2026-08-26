## Area3D-based nearby-enemy adapter для combat state.
extends RefCounted
class_name CombatAwareness


static func count_nearby_enemies(actor: Entity, state: C_CombatState) -> int:
	var area: Area3D = _resolve_area(actor, state)
	if area == null:
		return 0
	var seen: Array[Entity] = []
	for body in area.get_overlapping_bodies():
		var candidate: Entity = _entity_from_node(body as Node)
		if candidate == null or seen.has(candidate):
			continue
		seen.append(candidate)
	return _count_hostile(actor, seen)


static func _count_hostile(actor: Entity, candidates: Array[Entity]) -> int:
	var count: int = 0
	for candidate in candidates:
		if CombatRules.are_enemies(actor, candidate):
			count += 1
	return count


static func _resolve_area(actor: Entity, state: C_CombatState) -> Area3D:
	if actor == null or state == null:
		return null
	var actor_node: Node = actor as Node
	return actor_node.get_node_or_null(state.sensor_path) as Area3D if actor_node != null else null


static func _entity_from_node(node: Node) -> Entity:
	var current: Node = node
	while current != null:
		if current is Entity:
			return current as Entity
		current = current.get_parent()
	return null
