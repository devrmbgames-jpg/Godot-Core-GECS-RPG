## World-independent entry points for elemental damage, status applications and gauge lifetimes.
## HP and external side effects are deliberately handled by integration adapters.
extends RefCounted
class_name ElementalResolver


## Previews signed damage without mutating state, so team policy can distinguish harmful hits from affinity healing.
static func preview_damage(state: C_ElementalState, catalog: ElementalCatalog, damage_type: StringName, amount: float) -> float:
	if not catalog.has_damage_type(damage_type) or not _valid_amount(amount):
		return 0.0
	var result := amount * catalog.get_combined_status_multiplier(damage_type, state.active_statuses(catalog)) * catalog.get_resistance_multiplier(state.get_resistance(damage_type, catalog))
	return result if not is_nan(result) and not is_inf(result) else 0.0


## Calculates signed damage from the pre-impact snapshot, then accumulates gauges and resolves reactions.
## Incoming strength is independent of HP resistance; buildup_scale=0 explicitly disables damage buildup.
static func resolve_damage(state: C_ElementalState, catalog: ElementalCatalog, request: DamageRequest) -> ElementalResolution:
	var result := _begin(state, catalog, request.source, request.ability, request.hit_position, request.direction, request.chain, request.reaction_depth)
	result.damage_type = request.damage_type
	if not catalog.has_damage_type(request.damage_type) or not _valid_amount(request.amount):
		return _finish(state, catalog, result)
	var raw := maxf(0.0, request.amount)
	result.impact_strength = raw
	result.resistance = state.get_resistance(request.damage_type, catalog)
	result.signed_damage = preview_damage(state, catalog, request.damage_type, raw)
	if request.buildup_scale > 0.0 and _valid_amount(request.buildup_scale):
		for status_id in catalog.buildup_statuses(request.damage_type):
			var strength := raw * request.buildup_scale * catalog.get_buildup_rate(request.damage_type, status_id)
			if state.add_gauge(status_id, strength, catalog, request.source, request.ability) > 0.0:
				result.changed = true
	for application in request.status_applications:
		if application != null and state.add_gauge(application.status_id, application.amount, catalog, request.source, request.ability) > 0.0:
			result.changed = true
	ElementalReactionEngine.resolve(state, catalog, request.damage_type, raw, result)
	return _finish(state, catalog, result)


## Resolves a direct status command without any HP damage; REMOVE and CLEAR cannot create new reactions.
static func resolve_status(state: C_ElementalState, catalog: ElementalCatalog, request: ElementalStatusRequest) -> ElementalResolution:
	var result := _begin(state, catalog, request.source, request.ability, request.hit_position, request.direction, request.chain, request.reaction_depth)
	if catalog.get_status(request.status_id) == null:
		return _finish(state, catalog, result)
	match request.operation:
		ElementalStatusRequest.Operation.ADD:
			if state.add_gauge(request.status_id, request.amount, catalog, request.source, request.ability) > 0.0:
				result.changed = true
			result.impact_strength = maxf(0.0, request.amount) if _valid_amount(request.amount) else 0.0
			ElementalReactionEngine.resolve(state, catalog, &"", result.impact_strength, result)
		ElementalStatusRequest.Operation.REMOVE:
			result.changed = state.consume_gauge(request.status_id, request.amount) > 0.0
		ElementalStatusRequest.Operation.CLEAR:
			var before := state.get_amount(request.status_id)
			state.clear_gauge(request.status_id)
			result.changed = before > 0.0
	return _finish(state, catalog, result)


## Advances gauge lifetimes and decay. Decay cannot introduce a new reaction, so no chain is run.
static func tick(state: C_ElementalState, catalog: ElementalCatalog, delta: float) -> ElementalResolution:
	var result := _begin(state, catalog, null, null, Vector3.ZERO, Vector3.ZERO, null, 0)
	var before: Dictionary = {}
	for item in state.gauges:
		before[item.id] = item.revision
	state.advance(delta, catalog)
	for item in state.gauges:
		if item.revision != int(before.get(item.id, -1)):
			result.changed = true
	return _finish(state, catalog, result)


## Creates a request-local result with a shared chain budget and immutable initial status snapshot.
static func _begin(state: C_ElementalState, catalog: ElementalCatalog, source: Entity, ability: Entity, position: Vector3, direction: Vector3, chain: ElementalChain, depth: int) -> ElementalResolution:
	var result := ElementalResolution.new()
	result.status_before = state.active_statuses(catalog)
	result.source = source
	result.ability = ability
	result.hit_position = position
	result.direction = direction
	result.chain = chain if chain != null else ElementalChain.new()
	result.depth = depth
	return result


## Finalizes the status snapshot and propagates shared chain exhaustion.
static func _finish(state: C_ElementalState, catalog: ElementalCatalog, result: ElementalResolution) -> ElementalResolution:
	result.status_after = state.active_statuses(catalog)
	result.truncated = result.truncated or result.chain.truncated
	return result


## Accepts finite nonnegative magnitudes; negative damage is represented by resistance, never input.
static func _valid_amount(amount: float) -> bool:
	return amount >= 0.0 and not is_nan(amount) and not is_inf(amount)
