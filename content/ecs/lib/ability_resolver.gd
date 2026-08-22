## Stateless delivery resolver для AbilityDefinition.
## Здесь различаются механики доставки (melee/projectile), а не конкретные ability IDs.
extends RefCounted
class_name AbilityResolver

const EVENT_RESOLVED: StringName = &"ability_resolved"


static func resolve(actor: Entity, ability: Entity, target: Entity, target_position: Vector3, command_buffer: CommandBuffer) -> void:
	if actor == null or ability == null:
		return
	var ability_component := ability.get_component(C_Ability) as C_Ability
	if ability_component == null or ability_component.definition == null:
		return
	var definition := ability_component.definition
	var raw_damage := _calculate_raw_damage(actor, definition)
	match definition.delivery:
		AbilityDefinition.Delivery.MELEE:
			_resolve_melee(actor, ability, target, definition, raw_damage)
		AbilityDefinition.Delivery.PROJECTILE:
			var direction := _resolve_direction(actor, target, target_position)
			command_buffer.add_custom(func(): ProjectileFactory.spawn(actor, ability, definition, raw_damage, direction))
	ECS.world.emit_event(EVENT_RESOLVED, actor, AbilityResolvedEvent.new(ability, definition))


static func _calculate_raw_damage(actor: Entity, definition: AbilityDefinition) -> float:
	var damage_stat := actor.get_component(C_Damage) as C_Damage
	var actor_damage := damage_stat.value if damage_stat != null else 0.0
	return maxf(0.0, definition.flat_damage + actor_damage * definition.damage_scale)


static func _resolve_direction(actor: Entity, target: Entity, target_position: Vector3) -> Vector3:
	var actor_node := actor as Node as Node3D
	if actor_node == null:
		return Vector3.FORWARD
	if target != null and is_instance_valid(target):
		var target_node := target as Node as Node3D
		if target_node != null:
			return (target_node.global_position - actor_node.global_position).normalized()
	if target_position != Vector3.ZERO:
		return (target_position - actor_node.global_position).normalized()
	return CombatQuery.facing(actor)


static func _resolve_melee(actor: Entity, ability: Entity, target: Entity, definition: AbilityDefinition, raw_damage: float) -> void:
	var actor_node := actor as Node as Node3D
	if actor_node == null:
		return
	var origin := actor_node.global_position + Vector3.UP
	var direction := _resolve_direction(actor, target, Vector3.ZERO)
	var hit: CombatHit = CombatQuery.raycast_entity(actor, origin, origin + direction * definition.range)
	var victim := hit.entity if hit != null else null
	if victim == null or victim == actor or not CombatRules.can_damage(actor, victim):
		return
	DamageService.request(victim, DamageRequest.new(actor, ability, raw_damage, hit.position, direction))
	EffectService.request_all(victim, definition.effects, actor, ability)
