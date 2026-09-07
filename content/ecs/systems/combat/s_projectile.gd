## Swept-ray projectile simulation. Node3D transform — position authority.
extends System
class_name S_Projectile


## Выбирает spatial projectile Entities с C_Projectile runtime payload.
func query() -> QueryBuilder:
	return q.with_all([C_Projectile]).iterate([C_Projectile])


## Продвигает lifetime/Node3D position и делает swept ray между old/new position.
## На первом collision отдельно спавнит optional impact VFX, применяет elemental damage/effects и удаляет projectile.
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
			if projectile.definition != null:
				VFXSpawner.spawn_world(projectile.definition.impact_vfx_scene, hit.position, node)
			var victim := hit.entity
			if victim != null and victim != projectile.source and CombatRules.can_damage(projectile.source, victim):
				var definition := projectile.definition
				DamageService.request(
					victim,
					DamageRequest.new(
						projectile.source,
						projectile.ability,
						projectile.damage,
						hit.position,
						projectile.velocity.normalized(),
						DamageRequest.Kind.DIRECT,
						definition.damage_type if definition != null else &"PHYSICAL",
						definition.buildup_scale if definition != null else 1.0,
						definition.status_applications if definition != null else [],
					),
				)
				if definition != null:
					EffectService.request_all(victim, definition.effects, projectile.source, projectile.ability)
			cmd.remove_entity(entity)
			continue
		node.global_position = to
