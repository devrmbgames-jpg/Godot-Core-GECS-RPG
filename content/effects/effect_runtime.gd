## Stateless lifecycle/stacking operations для Effect Entity.
extends RefCounted
class_name EffectRuntime


static func apply(target: Entity, request: EffectApplyRequest) -> Entity:
	if ECS.world == null or target == null or request == null or request.definition == null:
		return null
	var definition := request.definition
	if definition.instant_heal > 0.0:
		HealService.request(target, HealRequest.new(request.source, request.ability, definition.instant_heal))
	if definition.duration <= 0.0:
		return null
	var matching := _find_effects(target, definition.id)
	match definition.stack_policy:
		EffectDefinition.StackPolicy.REFRESH:
			if not matching.is_empty():
				_refresh(matching[0], definition)
				return matching[0]
		EffectDefinition.StackPolicy.STACK:
			if not matching.is_empty():
				var effect := matching[0]
				var context := effect.get_component(C_EffectContext) as C_EffectContext
				context.stacks = mini(context.stacks + 1, maxi(definition.max_stacks, 1))
				_refresh(effect, definition)
				_sync_stat_modifiers(effect)
				return effect
		EffectDefinition.StackPolicy.REPLACE:
			for effect in matching:
				remove(effect)
		EffectDefinition.StackPolicy.INDEPENDENT:
			pass
	return _spawn(target, request)


static func remove(effect: Entity) -> void:
	if ECS.world == null or effect == null or not is_instance_valid(effect):
		return
	var context := effect.get_component(C_EffectContext) as C_EffectContext
	if context != null and context.target != null and is_instance_valid(context.target):
		_remove_stat_modifiers(context.target, effect)
		for relationship in context.target.get_relationships(Relationship.new(R_HasEffect.new(), E_Effect)):
			var data := relationship.relation as R_HasEffect
			if data != null and data.effect == effect:
				context.target.remove_relationship(relationship, 1)
				break
	ECS.world.remove_entity(effect)


static func _spawn(target: Entity, request: EffectApplyRequest) -> Entity:
	var definition := request.definition
	var effect := E_Effect.new()
	effect.name = "Effect_%s" % String(definition.id)
	effect.add_component(C_Effect.new(definition))
	effect.add_component(C_EffectContext.new(target, request.source, request.ability))
	effect.add_component(C_Duration.new(definition.duration))
	if definition.damage_per_tick > 0.0 or definition.heal_per_tick > 0.0:
		effect.add_component(C_EffectTick.new(definition.tick_interval))
	ECS.world.add_entity(effect, null, false)
	target.add_relationship(Relationship.new(R_HasEffect.new(effect, definition.id), E_Effect))
	_sync_stat_modifiers(effect)
	ECS.world.emit_event(
		&"presentation_action",
		target,
		{"action": definition.presentation_action, "phase": &"effect_applied", "effect": effect},
	)
	return effect


static func _refresh(effect: Entity, definition: EffectDefinition) -> void:
	var duration := effect.get_component(C_Duration) as C_Duration
	if duration != null:
		duration.remaining = definition.duration
	var tick := effect.get_component(C_EffectTick) as C_EffectTick
	if tick != null:
		tick.interval = maxf(definition.tick_interval, 0.001)
		tick.remaining = minf(tick.remaining, tick.interval)


static func _sync_stat_modifiers(effect: Entity) -> void:
	var effect_component := effect.get_component(C_Effect) as C_Effect
	var context := effect.get_component(C_EffectContext) as C_EffectContext
	if effect_component == null or effect_component.definition == null or context == null or context.target == null:
		return
	_remove_stat_modifiers(context.target, effect)
	for modifier_definition in effect_component.definition.stat_modifiers:
		if modifier_definition == null or modifier_definition.stat_type == null:
			continue
		context.target.add_relationship(
			Relationship.new(
				R_ModifiesStat.new(
					effect,
					modifier_definition.operation,
					modifier_definition.amount * context.stacks,
				),
				modifier_definition.stat_type,
			)
		)


static func _remove_stat_modifiers(target: Entity, effect: Entity) -> void:
	for relationship in target.get_relationships(Relationship.new(R_ModifiesStat.new(), null)):
		var modifier := relationship.relation as R_ModifiesStat
		if modifier != null and modifier.modifier_source == effect:
			target.remove_relationship(relationship, 1)


static func _find_effects(target: Entity, effect_id: StringName) -> Array[Entity]:
	var result: Array[Entity] = []
	for relationship in target.get_relationships(Relationship.new(R_HasEffect.new(), E_Effect)):
		var data := relationship.relation as R_HasEffect
		if data != null and data.effect_id == effect_id and is_instance_valid(data.effect):
			result.append(data.effect)
	return result
