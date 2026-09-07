## Pure reaction interpreter. It changes only C_ElementalState and returns typed external action intents.
extends RefCounted
class_name ElementalReactionEngine

const MAX_RULES: int = 32
const EPSILON: float = 0.0001


## Selects the highest-priority eligible rule after each mutation. A rule executes once per impact.
## Repeated states, the rule cap and a shared action budget prevent unbounded reaction chains.
static func resolve(state: C_ElementalState, catalog: ElementalCatalog, incoming: StringName, impact: float, result: ElementalResolution) -> void:
	var executed: Dictionary = {}
	var seen_states: Dictionary = {}
	seen_states[_signature(state)] = true
	for _step in MAX_RULES:
		var candidates: Array[ElementalRule] = []
		if incoming != &"":
			candidates.append_array(catalog.matching_rules(&"damage", incoming, state))
		candidates.append_array(catalog.matching_rules(&"status", &"", state))
		candidates.append_array(catalog.matching_rules(&"material", state.material, state))
		candidates.sort_custom(func(a: ElementalRule, b: ElementalRule) -> bool:
			if a.priority == b.priority:
				return String(a.id) < String(b.id)
			return a.priority > b.priority
		)
		var selected: ElementalRule
		for rule in candidates:
			if not executed.has(rule.id):
				selected = rule
				break
		if selected == null:
			return
		executed[selected.id] = true
		var before := _signature(state)
		var actions_before := result.actions.size()
		var strength := impact
		if selected.trigger == &"status" and selected.required_status != &"":
			strength = minf(state.get_amount(selected.incoming), state.get_amount(selected.required_status))
		var applied := false
		for action in selected.actions:
			if not result.chain.spend():
				result.truncated = true
				return
			applied = _execute_action(state, catalog, action, strength, impact, selected.id, result) or applied
		var after := _signature(state)
		if before != after:
			result.changed = true
			applied = true
		if result.actions.size() > actions_before:
			applied = true
		if not applied:
			continue
		result.fired_rules.append(selected.id)
		if before != after:
			if seen_states.has(after):
				result.truncated = true
				return
			seen_states[after] = true
	result.truncated = true


## Executes one action and returns whether it mutated state or queued an external action.
static func _execute_action(state: C_ElementalState, catalog: ElementalCatalog, action: ElementalAction, strength: float, impact: float, rule_id: StringName, result: ElementalResolution) -> bool:
	if action == null:
		return false
	var magnitude := impact if action.use_impact else action.magnitude(strength)
	if is_nan(magnitude) or is_inf(magnitude):
		return false
	match action.kind:
		ElementalAction.Kind.EXCHANGE:
			var first_amount := state.get_amount(action.status_id)
			var second_amount := state.get_amount(action.other_status)
			var exchange := minf(first_amount, second_amount)
			if action.amount > 0.0 or action.scale > 0.0:
				exchange = minf(exchange, action.magnitude(strength))
			if exchange <= EPSILON or exchange < action.minimum:
				return false
			var exhausted := exchange >= first_amount - EPSILON or exchange >= second_amount - EPSILON
			if action.require_exhausted and not exhausted:
				return false
			var first_consumed := state.consume_gauge(action.status_id, exchange)
			var second_consumed := state.consume_gauge(action.other_status, exchange)
			var changed := first_consumed > EPSILON or second_consumed > EPSILON
			if action.output_status != &"" and (not action.output_on_exhausted or exhausted):
				changed = state.add_gauge(action.output_status, exchange * action.output_scale, catalog, result.source, result.ability) > EPSILON or changed
			return changed
		ElementalAction.Kind.ADD_GAUGE:
			return magnitude >= action.minimum and state.add_gauge(action.status_id, magnitude, catalog, result.source, result.ability) > EPSILON
		ElementalAction.Kind.REMOVE_GAUGE:
			return magnitude >= action.minimum and state.consume_gauge(action.status_id, magnitude) > EPSILON
		ElementalAction.Kind.TRANSFORM:
			if action.material_id == &"" or state.material == action.material_id:
				return false
			result.actions.append(ElementalActionExecution.new(action, strength, rule_id))
			return true
		ElementalAction.Kind.ADD_TAG:
			return state.add_tag(action.tag)
		ElementalAction.Kind.REMOVE_TAG:
			return state.remove_tag(action.tag)
		ElementalAction.Kind.DAMAGE:
			if magnitude <= EPSILON or not catalog.has_damage_type(action.damage_type):
				return false
			result.actions.append(ElementalActionExecution.new(action, strength, rule_id))
			return true
		ElementalAction.Kind.APPLY_EFFECT:
			if action.effect == null:
				return false
			result.actions.append(ElementalActionExecution.new(action, strength, rule_id))
			return true
		ElementalAction.Kind.SPAWN:
			if action.entity_id == &"":
				return false
			result.actions.append(ElementalActionExecution.new(action, strength, rule_id))
			return true
	return false


## Produces a stable reaction-state signature independent of gauge insertion order and object identity.
static func _signature(state: C_ElementalState) -> String:
	var parts := PackedStringArray([String(state.material)])
	var all_tags: Array[StringName] = []
	for tag in state.tags:
		if not all_tags.has(tag):
			all_tags.append(tag)
	for tag in state.material_tags:
		if not all_tags.has(tag):
			all_tags.append(tag)
	all_tags.sort()
	for tag in all_tags:
		parts.append(String(tag))
	var gauges: Array[ElementalGauge] = state.gauges.duplicate()
	gauges.sort_custom(func(a: ElementalGauge, b: ElementalGauge) -> bool: return String(a.id) < String(b.id))
	for item in gauges:
		parts.append("%s=%d" % [String(item.id), roundi(item.amount * 10000.0)])
	return "|".join(parts)
