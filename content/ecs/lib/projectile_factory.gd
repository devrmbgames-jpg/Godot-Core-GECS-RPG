## Stateless factory для generic projectile scene.
extends RefCounted
class_name ProjectileFactory

const PROJECTILE_SCENE: PackedScene = preload("res://content/ecs/entities/combat/e_projectile.tscn")


## Инстанцирует spatial projectile Node3D, задаёт initial transform/C_Projectile и регистрирует в ECS.world.
## Возвращает runtime projectile Entity либо null, если actor/scene не могут дать Node3D context.
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
	ECS.world.add_entity(projectile)
	return projectile
