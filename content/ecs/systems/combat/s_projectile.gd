## Swept-ray projectile simulation. Node3D transform — position authority.
extends System
class_name S_Projectile


func query() -> QueryBuilder:
	return q.with_all([C_Projectile]).iterate([C_Projectile])


func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var projectiles: Array = components[0]
	for index in entities.size():
		var entity := entities[index]
		var projectile := projectiles[index] as C_Projectile
		var node := entity as Node as Node3D
		if node == null:
			cmd.remove_entity(entity)
			continue
		projectile.remaining_lifetime -= delta
		if projectile.remaining_lifetime <= 0.0:
			cmd.remove_entity(entity)
			continue
		var from := node.global_position
		var to := from + projectile.velocity * delta
		var hit: CombatHit = CombatQuery.raycast_entity(projectile.source, from, to)
		if hit != null:
			var victim := hit.entity
			if victim != null and victim != projectile.source and CombatRules.can_damage(projectile.source, victim):
				DamageService.request(
					victim,
					DamageRequest.new(
						projectile.source,
						projectile.ability,
						projectile.damage,
						hit.position,
						projectile.velocity.normalized(),
					),
				)
				if projectile.definition != null:
					EffectService.request_all(victim, projectile.definition.effects, projectile.source, projectile.ability)
			cmd.remove_entity(entity)
			continue
		node.global_position = to
