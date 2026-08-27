## Stateless factory для generic projectile scene.
extends RefCounted
class_name ProjectileFactory

const PROJECTILE_SCENE: PackedScene = preload("res://content/ecs/entities/combat/e_projectile.tscn")


## Инстанцирует spatial projectile Node3D, задаёт initial transform/C_Projectile и регистрирует в ECS.world.
## Optional AbilityDefinition.projectile_visual_scene заменяет generic fallback mesh только визуально.
static func spawn(
	actor: Entity,
	ability: Entity,
	definition: AbilityDefinition,
	damage: float,
	direction: Vector3,
) -> Entity:
	if ECS.world == null or actor == null or definition == null:
		return null
	var projectile := PROJECTILE_SCENE.instantiate() as Entity
	if projectile == null:
		return null
	var projectile_node := projectile as Node as Node3D
	var actor_node := actor as Node as Node3D
	if projectile_node == null or actor_node == null:
		projectile.free()
		return null
	projectile_node.global_position = actor_node.global_position + Vector3.UP
	var normalized_direction := direction.normalized() if direction.length_squared() > 0.0001 else CombatQuery.facing(actor)
	projectile.add_component(
		C_Projectile.new(
			normalized_direction * definition.projectile_speed,
			damage,
			definition.projectile_lifetime,
			actor,
			ability,
			definition,
		)
	)
	_attach_visual(projectile_node, definition)
	ECS.world.add_entity(projectile)
	return projectile


## Attaches ability-specific flight visual and hides the generic projectile mesh when successful.
static func _attach_visual(projectile: Node3D, definition: AbilityDefinition) -> void:
	if projectile == null or definition == null or definition.projectile_visual_scene == null:
		return
	var raw_visual := definition.projectile_visual_scene.instantiate()
	var visual := raw_visual as Node3D
	if visual == null:
		raw_visual.free()
		return
	var fallback := projectile.get_node_or_null("Mesh") as GeometryInstance3D
	if fallback != null:
		fallback.visible = false
	projectile.add_child(visual)
