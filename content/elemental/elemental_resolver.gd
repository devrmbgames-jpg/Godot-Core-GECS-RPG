## Deterministic resolver for typed damage, buildup and bounded reaction chains.
extends RefCounted
class_name ElementalResolver


## Calculates status/resistance multipliers, resolves pre-buildup reactions, then accumulates linked status.
## Health mutation and armor remain owned by O_Damage; negative result means healing.
static func resolve_damage(
	target: Entity,
	request: DamageRequest,
	catalog: ElementalCatalog,
) -> ElementalDamageResolution:
	if request == null:
		return ElementalDamageResolution.new()
	var result := ElementalDamageResolution.new(request.damage_type, request.amount)
	if target == null or catalog == null:
		return result
	var context := request.elemental_context
	if context == null:
		context = ElementalResolutionContext.new()
		request.elemental_context = context
	if not context.try_enter():
		return result
	var state := target.get_component(C_ElementalState) as C_ElementalState
	var profile := target.get_component(C_DamageResistances) as C_DamageResistances
	result.status_multiplier = _get_combined_status_multiplier(state, catalog, request.damage_type)
	result.resistance_level = ElementalResistanceResolver.get_final_resistance(profile, state, catalog, request.damage_type)
	result.resistance_multiplier = catalog.get_resistance_multiplier(result.resistance_level)
	result.health_amount_before_armor = result.raw_amount * result.status_multiplier * result.resistance_multiplier
	var impact_matches := _collect_damage_reactions(request, state, catalog)
	impact_matches.append_array(_collect_material_reactions(target, request, catalog))
	_enqueue_matches(target, impact_matches, request.source, request.ability, request.hit_position, request.direction, context)
	_drain_actions(target, catalog, context)
	var damage_definition := catalog.get_damage_type(request.damage_type)
	if state != null and damage_definition != null and damage_definition.buildup_status_id != &"":
		result.buildup_applied = result.raw_amount * damage_definition.buildup_per_damage * request.status_buildup_scale
		if result.buildup_applied > 0.0:
			var status_request := ElementalStatusRequest.new(
				request.source, request.ability, damage_definition.buildup_status_id,
				result.buildup_applied, context, request.hit_position, request.direction,
			)
			var status_result := apply_status(target, status_request, catalog)
			result.buildup_transition = status_result.transition
	_drain_actions(target, catalog, context)
	result.triggered_reactions.append_array(context.triggered_reaction_ids)
	context.leave()
	return result


## Applies direct buildup with immunity and threshold handling, then schedules status+status reactions.
static func apply_status(
	target: Entity,
	request: ElementalStatusRequest,
	catalog: ElementalCatalog,
) -> ElementalStatusResolvedEvent:
	var result := ElementalStatusResolvedEvent.new(request)
	if target == null or request == null or catalog == null or request.buildup_amount <= 0.0:
		return result
	var context := request.context
	if context == null:
		context = ElementalResolutionContext.new()
		request.context = context
	if not context.try_enter():
		return result
	var before_reaction_count := context.triggered_reaction_ids.size()
	var immunities := target.get_component(C_StatusImmunities) as C_StatusImmunities
	if immunities != null and immunities.is_immune(request.status_id):
		result.ignored_by_immunity = true
		context.leave()
		_emit_status_result(target, result)
		return result
	var state := target.get_component(C_ElementalState) as C_ElementalState
	var definition := catalog.get_status(request.status_id)
	if state == null or definition == null:
		context.leave()
		_emit_status_result(target, result)
		return result
	result.transition = state.apply_status(definition, request.buildup_amount, request.source, request.ability)
	var applied_state := state.get_status(request.status_id)
	if applied_state != null and applied_state.active:
		_enqueue_status_reactions(target, request, state, applied_state, catalog, context)
	_drain_actions(target, catalog, context)
	for index in range(before_reaction_count, context.triggered_reaction_ids.size()):
		result.triggered_reactions.append(context.triggered_reaction_ids[index])
	context.leave()
	_emit_status_result(target, result)
	return result


## Multiplies all active sparse status modifiers; unspecified pairs contribute 1.0.
static func _get_combined_status_multiplier(
	state: C_ElementalState,
	catalog: ElementalCatalog,
	damage_type: StringName,
) -> float:
	var multiplier := 1.0
	if state == null:
		return multiplier
	for status_id in state.get_active_status_ids():
		multiplier *= catalog.get_damage_multiplier(damage_type, status_id)
	return multiplier


## Collects damage+active-status reactions using only power that can interact with existing buildup.
static func _collect_damage_reactions(
	request: DamageRequest,
	state: C_ElementalState,
	catalog: ElementalCatalog,
) -> Array[ElementalReactionMatch]:
	var matches: Array[ElementalReactionMatch] = []
	if state == null:
		return matches
	var impact_power := request.amount * request.status_buildup_scale
	for status in state.statuses:
		if not status.active or status.definition == null:
			continue
		var power := minf(impact_power, status.buildup)
		for reaction in catalog.get_reactions(
			ElementalReactionDefinition.TriggerKind.DAMAGE_STATUS,
			request.damage_type,
			status.definition.id,
		):
			matches.append(ElementalReactionMatch.new(reaction, power))
	return matches


## Collects damage+material reactions for environment tags on the same subject.
static func _collect_material_reactions(
	target: Entity,
	request: DamageRequest,
	catalog: ElementalCatalog,
) -> Array[ElementalReactionMatch]:
	var matches: Array[ElementalReactionMatch] = []
	var materials := target.get_component(C_ReactiveMaterials) as C_ReactiveMaterials
	if materials == null:
		return matches
	for material_id in materials.material_ids.duplicate():
		for reaction in catalog.get_reactions(
			ElementalReactionDefinition.TriggerKind.DAMAGE_MATERIAL,
			request.damage_type,
			material_id,
		):
			matches.append(ElementalReactionMatch.new(reaction, request.amount))
	return matches


## Queues reactions between the newly strengthened active status and every other active status.
static func _enqueue_status_reactions(
	target: Entity,
	request: ElementalStatusRequest,
	state: C_ElementalState,
	applied_state: ElementalStatusState,
	catalog: ElementalCatalog,
	context: ElementalResolutionContext,
) -> void:
	var matches: Array[ElementalReactionMatch] = []
	for other in state.statuses:
		if other == applied_state or not other.active or other.definition == null:
			continue
		var power := minf(applied_state.buildup, other.buildup)
		for reaction in catalog.get_reactions(
			ElementalReactionDefinition.TriggerKind.STATUS_STATUS,
			applied_state.definition.id,
			other.definition.id,
		):
			matches.append(ElementalReactionMatch.new(reaction, power))
	_enqueue_matches(target, matches, request.source, request.ability, request.hit_position, request.direction, context)


## Sorts candidates globally by priority before placing their actions in the FIFO queue.
static func _enqueue_matches(
	target: Entity,
	matches: Array[ElementalReactionMatch],
	source: Entity,
	ability: Entity,
	hit_position: Vector3,
	direction: Vector3,
	context: ElementalResolutionContext,
) -> void:
	matches.sort_custom(_sort_matches)
	for reaction_match in matches:
		_enqueue_reaction(
			target, reaction_match.reaction, reaction_match.power, source, ability,
			hit_position, direction, context,
		)


## Orders reaction candidates by descending priority and stable reaction ID.
static func _sort_matches(left: ElementalReactionMatch, right: ElementalReactionMatch) -> bool:
	if left.reaction.priority != right.reaction.priority:
		return left.reaction.priority > right.reaction.priority
	return String(left.reaction.id) < String(right.reaction.id)


## Marks one reaction and appends its ordered actions to the shared FIFO queue.
static func _enqueue_reaction(
	target: Entity,
	reaction: ElementalReactionDefinition,
	power: float,
	source: Entity,
	ability: Entity,
	hit_position: Vector3,
	direction: Vector3,
	context: ElementalResolutionContext,
) -> void:
	if reaction == null or power <= 0.0 or not context.try_mark_reaction(target, reaction.id):
		return
	if ECS.world != null:
		ECS.world.emit_event(
			ElementalService.EVENT_REACTION_TRIGGERED,
			target,
			ElementalReactionEvent.new(reaction.id, power, source, ability),
		)
	for action in reaction.actions:
		context.enqueue(ElementalQueuedAction.new(action, reaction.id, power, source, ability, hit_position, direction))


## Drains one root queue unless an outer resolver frame is already processing it.
static func _drain_actions(target: Entity, catalog: ElementalCatalog, context: ElementalResolutionContext) -> void:
	if context.processing_queue:
		return
	context.processing_queue = true
	while not context.action_queue.is_empty() and context.remaining_actions > 0:
		var queued := context.pop_next()
		if queued != null:
			ElementalActionExecutor.execute(target, queued, catalog, context)
	context.processing_queue = false


## Emits a typed status result when an ECS world is available.
static func _emit_status_result(target: Entity, result: ElementalStatusResolvedEvent) -> void:
	if ECS.world != null:
		ECS.world.emit_event(ElementalService.EVENT_STATUS_RESOLVED, target, result)
