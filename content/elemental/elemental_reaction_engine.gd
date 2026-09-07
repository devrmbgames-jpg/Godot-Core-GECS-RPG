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
	for step in MAX_RULES:
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
		result.fired_rules.append(selected.id)
		var before := _signature(state)
		var strength := impact
		if selected.trigger == &"status" and selected.required_status != &"":
			strength = minf(state.get_amount(selected.incoming), state.get_amount(selected.required_status))
		for action in selected.actions:
			if not result.chain.spend():
				result.truncated = true
				return
			_execute_action(state, catalog, action, strength, impact, selected.id, result)
		var after := _signature(state)
		if before != after:
			result.changed = true
			if seen_states.has(after):
				result.truncated = true
				return
			seen_states[after] = true
	result.truncated = true


## Executes gauge/material instructions and queues damage, effects, spawning and spatial transformations.
static func _execute_action(state: C_ElementalState, catalog: ElementalCatalog, action: ElementalAction, strength: float, impact: float, rule_id: StringName, result: ElementalResolution) -> void:
	if action == null:
		return
	var magnitude := impact if action.use_impact else action.magnitude(strength)
	if is_nan(magnitude) or is_inf(magnitude):
		return
	match action.kind:
		ElementalAction.Kind.EXCHANGE:
			var available := minf(state.get_amount(action.status_id), state.get_amount(action.other_status))
			var exchange := available
			if action.amount > 0.0 or action.scale > 0.0:
				exchange = minf(exchange, action.magnitude(strength))
			if exchange <= EPSILON or exchange < action.minimum:
				return
			var exhausted := exchange >= state.get_amount(action.status_id) - EPSILON or exchange >= state.get_amount(action.other_status) - EPSILON
			if action.require_exhausted and not exhausted:
				return
			state.consume_gauge(action.status_id, exchange)
			state.consume_gauge(action.other_status, exchange)
			if action.output_status != &"" and (not action.output_on_exhausted or exhausted):
				state.add_gauge(action.output_status, exchange * action.output_scale, catalog, result.source, result.ability)
		ElementalAction.Kind.ADD_GAUGE:
			if magnitude >= action.minimum:
				state.add_gauge(action.status_id, magnitude, catalog, result.source, result.ability)
		ElementalAction.Kind.REMOVE_GAUGE:
			if magnitude >= action.minimum:
				state.consume_gauge(action.status_id, magnitude)
		ElementalAction.Kind.TRANSFORM:
			if action.material_id != &"" and state.material != action.material_id:
				state.material = action.material_id
				result.actions.append(ElementalActionExecution.new(action, strength, rule_id))
		ElementalAction.Kind.ADD_TAG:
			if action.tag != &"" and not state.tags.has(action.tag):
				state.tags.append(action.tag)
		ElementalAction.Kind.REMOVE_TAG:
			state.tags.erase(action.tag)
		ElementalAction.Kind.DAMAGE:
			if magnitude > 0.0 and catalog.has_damage_type(action.damage_type):
				result.actions.append(ElementalActionExecution.new(action, strength, rule_id))
		ElementalAction.Kind.APPLY_EFFECT:
			if action.effect != null:
				result.actions.append(ElementalActionExecution.new(action, strength, rule_id))
		ElementalAction.Kind.SPAWN:
			if action.entity_id != &"":
				result.actions.append(ElementalActionExecution.new(action, strength, rule_id))


## Produces a stable reaction-state signature independent of gauge insertion order and object identity.
static func _signature(state: C_ElementalState) -> String:
	var parts := PackedStringArray([String(state.material)])
	var tags := PackedStringArray()
	for tag in state.tags:
		tags.append(String(tag))
	tags.sort()
	parts.append_array(tags)
	var gauges: Array[ElementalGauge] = state.gauges.duplicate()
	gauges.sort_custom(func(a: ElementalGauge, b: ElementalGauge) -> bool: return String(a.id) < String(b.id))
	for item in gauges:
		parts.append("%s=%d" % [String(item.id), roundi(item.amount * 10000.0)])
	return "|".join(parts)
