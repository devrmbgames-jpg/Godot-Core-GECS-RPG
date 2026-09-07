## Выполняет periodic damage/heal ticks активных Effect Entity.
extends System
class_name S_EffectTick


## Выбирает effects с definition, runtime context и periodic clock.
func query() -> QueryBuilder:
	return q.with_all([C_Effect, C_EffectContext, C_EffectTick]).iterate([C_Effect, C_EffectContext, C_EffectTick])


## Выполняет накопившиеся ticks, масштабирует amount stacks и публикует typed damage/heal requests.
## Periodic damage не удерживает combat linger; buildup explicitly controlled by EffectDefinition.
func process(_entities: Array[Entity], components: Array, delta: float) -> void:
	var effects: Array = components[0]
	var contexts: Array = components[1]
	var ticks: Array = components[2]
	for index in effects.size():
		var effect_component := effects[index] as C_Effect
		var context := contexts[index] as C_EffectContext
		var tick := ticks[index] as C_EffectTick
		if effect_component.definition == null or context.target == null or not is_instance_valid(context.target):
			continue
		tick.remaining -= delta
		while tick.remaining <= 0.0:
			tick.remaining += maxf(tick.interval, 0.001)
			var definition := effect_component.definition
			var stacks := maxi(context.stacks, 1)
			if definition.damage_per_tick > 0.0:
				DamageService.request(
					context.target,
					DamageRequest.new(
						context.source,
						context.ability,
						definition.damage_per_tick * stacks,
						Vector3.ZERO,
						Vector3.ZERO,
						DamageRequest.Kind.PERIODIC,
						definition.damage_type,
						definition.buildup_scale,
						definition.status_applications,
					),
				)
			elif not definition.status_applications.is_empty():
				for application in definition.status_applications:
					if application != null:
						ElementalService.apply_status(context.target, application.status_id, application.amount * stacks, context.source, context.ability)
			if definition.heal_per_tick > 0.0:
				HealService.request(
					context.target,
					HealRequest.new(context.source, context.ability, definition.heal_per_tick * stacks),
				)
