## Stateless Godot-physics queries, возвращающие gameplay Entity.
extends RefCounted
class_name CombatQuery


## Возвращает первую Entity на ray, игнорируя source CollisionObject3D.
static func raycast_entity(source: Entity, from: Vector3, to: Vector3) -> Dictionary:
	var source_node := source as Node as Node3D
	if source_node == null or source_node.get_world_3d() == null:
		return {}
	var parameters := PhysicsRayQueryParameters3D.create(from, to)
	var collision_source := source as Node as CollisionObject3D
	if collision_source != null:
		parameters.exclude = [collision_source.get_rid()]
	var hit := source_node.get_world_3d().direct_space_state.intersect_ray(parameters)
	if hit.is_empty():
		return {}
	var node := hit.get("collider") as Node
	while node != null and not (node is Entity):
		node = node.get_parent()
	hit["entity"] = node as Entity
	return hit


## World-space direction actor currently intends to face.
static func facing(actor: Entity) -> Vector3:
	var intent := actor.get_component(C_ControllerIntent) as C_ControllerIntent
	if intent != null:
		var direction := intent.facing_direction
		if direction.length_squared() <= 0.0001:
			direction = intent.move_direction
		direction.y = 0.0
		if direction.length_squared() > 0.0001:
			return direction.normalized()
	var node := actor as Node as Node3D
	return -node.global_basis.z.normalized() if node != null else Vector3.FORWARD
