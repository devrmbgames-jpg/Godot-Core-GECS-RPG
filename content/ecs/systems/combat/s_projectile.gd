## Swept-ray projectile simulation. Node3D transform — position authority.
extends System
class_name S_Projectile


## Выбирает spatial projectile Entities с C_Projectile runtime payload.
func query() -> QueryBuilder:
	return q.with_all([C_Projectile]).iterate([C_Projectile])


## Продвигает lifetime/Node3D position и делает swept ray между old/new position.
## На первом collision отдельно спавнит optional impact VFX, применяет damage/effects к valid victim и удаляет projectile.
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
				var damage_type := projectile.definition.damage_type if projectile.definition != null else ElementalIds.DAMAGE_PHYSICAL
				var buildup_scale := projectile.definition.status_buildup_scale if projectile.definition != null else 1.0
				var elemental_context := ElementalResolutionContext.new()
				DamageService.request(
					victim,
					DamageRequest.new(
						projectile.source,
						projectile.ability,
						projectile.damage,
						hit.position,
						projectile.velocity.normalized(),
						DamageRequest.Kind.DIRECT,
						damage_type,
						buildup_scale,
						elemental_context,
					),
				)
				if projectile.definition != null:
					ElementalService.request_statuses(
						victim, projectile.definition.elemental_statuses, projectile.source,
						projectile.ability, hit.position, projectile.velocity.normalized(),
						elemental_context,
					)
					EffectService.request_all(victim, projectile.definition.effects, projectile.source, projectile.ability)
			cmd.remove_entity(entity)
			continue
		node.global_position = to
