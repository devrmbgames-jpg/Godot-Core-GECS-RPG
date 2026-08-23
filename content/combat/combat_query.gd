## Stateless Godot-physics queries, возвращающие typed gameplay results.
extends RefCounted
class_name CombatQuery


## Возвращает typed CombatHit для первого physics hit, игнорируя source CollisionObject3D.
##
## Dictionary существует только локально, потому что PhysicsDirectSpaceState3D.intersect_ray()
## является Godot API с Dictionary return type. Строковые ключи не выходят из этого adapter.
static func raycast_entity(source: Entity, from: Vector3, to: Vector3) -> CombatHit:
	var source_node := source as Node as Node3D
	if source_node == null or source_node.get_world_3d() == null:
		return null
	var parameters := PhysicsRayQueryParameters3D.create(from, to)
	var collision_source := source as Node as CollisionObject3D
	if collision_source != null:
		parameters.exclude = [collision_source.get_rid()]
	var raw_hit: Dictionary = source_node.get_world_3d().direct_space_state.intersect_ray(parameters)
	if raw_hit.is_empty():
		return null
	var node := raw_hit.get("collider") as Node
	while node != null and not (node is Entity):
		node = node.get_parent()
	var hit_position: Vector3 = raw_hit.get("position", to)
	var hit_normal: Vector3 = raw_hit.get("normal", Vector3.ZERO)
	return CombatHit.new(node as Entity, hit_position, hit_normal)


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
