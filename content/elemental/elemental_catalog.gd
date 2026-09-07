## Data boundary for elemental definitions and tables. Gameplay queries typed records, never storage rows.
extends Resource
class_name ElementalCatalog

## Adapter-owned tables. Treat a configured catalog as immutable during gameplay.
var damage_types: Array[StringName] = []
var statuses: Dictionary = {}
var damage_buildup: Dictionary = {}
var damage_multipliers: Dictionary = {}
var resistance_multipliers: Dictionary = {}
var base_resistances: Dictionary = {}
var rules: Array[ElementalRule] = []


## Builds a catalog from storage-neutral rows; the same schema can be populated by a future CSV reader.
static func from_tables(tables: Dictionary) -> ElementalCatalog:
	var catalog := ElementalCatalog.new()
	for id in tables.get("damage_types", []):
		var damage_id := StringName(id)
		if damage_id != &"" and not catalog.damage_types.has(damage_id):
			catalog.damage_types.append(damage_id)
	catalog.damage_types.sort()
	catalog.damage_buildup = (tables.get("damage_buildup", {}) as Dictionary).duplicate(true)
	catalog.damage_multipliers = (tables.get("damage_multipliers", {}) as Dictionary).duplicate(true)
	catalog.resistance_multipliers = (tables.get("resistance_multipliers", {}) as Dictionary).duplicate(true)
	catalog.base_resistances = (tables.get("base_resistances", {}) as Dictionary).duplicate(true)
	var status_rows: Dictionary = tables.get("statuses", {})
	for id in status_rows:
		var row: Dictionary = status_rows[id]
		var definition := ElementalStatusDefinition.new()
		definition.id = StringName(id)
		definition.threshold = float(row.get("threshold", 20.0))
		definition.max_gauge = float(row.get("max_gauge", 200.0))
		definition.duration = float(row.get("duration", 8.0))
		definition.decay_per_second = float(row.get("decay_per_second", 0.0))
		definition.effect = row.get("effect") as EffectDefinition
		for modifier_row in row.get("resistance_modifiers", []):
			var modifier := ElementalResistanceModifier.new()
			modifier.category = StringName(modifier_row.get("category", "status"))
			modifier.source_id = StringName(modifier_row.get("source_id", id))
			modifier.damage_type = StringName(modifier_row.get("damage_type", "PHYSICAL"))
			modifier.amount = int(modifier_row.get("amount", 0))
			definition.resistance_modifiers.append(modifier)
		catalog.statuses[definition.id] = definition
	for row in tables.get("rules", []):
		var rule := ElementalRule.new()
		rule.id = StringName(row.get("id", ""))
		rule.trigger = StringName(row.get("trigger", "damage"))
		rule.incoming = StringName(row.get("incoming", ""))
		rule.required_status = StringName(row.get("required_status", ""))
		rule.required_tag = StringName(row.get("required_tag", ""))
		rule.minimum_gauge = float(row.get("minimum_gauge", 0.0))
		rule.priority = int(row.get("priority", 0))
		for action_row in row.get("actions", []):
			rule.actions.append(_action_from_row(action_row))
		catalog.rules.append(rule)
	return catalog


## Converts one storage action to a typed instruction. Invalid symbolic/integer kinds stay invalid for validate().
static func _action_from_row(row: Dictionary) -> ElementalAction:
	var action := ElementalAction.new()
	var raw_kind: Variant = row.get("kind", "ADD_GAUGE")
	if raw_kind is String or raw_kind is StringName:
		action.kind = int(ElementalAction.Kind.get(String(raw_kind).to_upper(), -1))
	else:
		action.kind = int(raw_kind)
	action.status_id = StringName(row.get("status_id", ""))
	action.other_status = StringName(row.get("other_status", ""))
	action.output_status = StringName(row.get("output_status", ""))
	action.damage_type = StringName(row.get("damage_type", "PHYSICAL"))
	action.entity_id = StringName(row.get("entity_id", ""))
	action.material_id = StringName(row.get("material_id", ""))
	action.tag = StringName(row.get("tag", ""))
	action.amount = float(row.get("amount", 0.0))
	action.scale = float(row.get("scale", 0.0))
	action.minimum = float(row.get("minimum", 0.0))
	action.output_scale = float(row.get("output_scale", 1.0))
	action.use_impact = bool(row.get("use_impact", false))
	action.output_on_exhausted = bool(row.get("output_on_exhausted", false))
	action.require_exhausted = bool(row.get("require_exhausted", false))
	action.allow_buildup = bool(row.get("allow_buildup", false))
	action.effect = row.get("effect") as EffectDefinition
	return action


## Reports invalid definitions, non-finite numbers and broken references before gameplay uses the catalog.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if damage_types.is_empty():
		errors.append("No damage types configured")
	for id in damage_types:
		if id == &"":
			errors.append("Empty damage type")
	for id in statuses:
		var definition := get_status(StringName(id))
		if definition == null or not definition.is_valid_definition():
			errors.append("Invalid status: %s" % String(id))
			continue
		for modifier in definition.resistance_modifiers:
			if modifier == null or modifier.category == &"" or modifier.source_id == &"" or not has_damage_type(modifier.damage_type):
				errors.append("Invalid resistance modifier on status: %s" % String(id))
	for damage_type in damage_buildup:
		if not has_damage_type(StringName(damage_type)):
			errors.append("Unknown buildup damage type: %s" % String(damage_type))
		var row: Dictionary = damage_buildup[damage_type]
		for status_id in row:
			if get_status(StringName(status_id)) == null:
				errors.append("Unknown buildup status: %s" % String(status_id))
			if not _finite_nonnegative(float(row[status_id])):
				errors.append("Invalid buildup rate: %s/%s" % [String(damage_type), String(status_id)])
	for damage_type in damage_multipliers:
		if not has_damage_type(StringName(damage_type)):
			errors.append("Unknown multiplier damage type: %s" % String(damage_type))
		var row: Dictionary = damage_multipliers[damage_type]
		for status_id in row:
			if get_status(StringName(status_id)) == null:
				errors.append("Unknown multiplier status: %s" % String(status_id))
			if not _finite_nonnegative(float(row[status_id])):
				errors.append("Invalid damage multiplier: %s/%s" % [String(damage_type), String(status_id)])
	for tier in range(-1, 5):
		if not resistance_multipliers.has(tier) or not _finite(float(resistance_multipliers[tier])):
			errors.append("Invalid resistance multiplier tier: %d" % tier)
	for target_type in base_resistances:
		var row: Dictionary = base_resistances[target_type]
		for damage_type in row:
			if not has_damage_type(StringName(damage_type)):
				errors.append("Unknown base resistance damage type: %s" % String(damage_type))
			var value := int(row[damage_type])
			if value < -1 or value > 4:
				errors.append("Base resistance out of range: %s/%s" % [String(target_type), String(damage_type)])
	var rule_ids: Dictionary = {}
	for rule in rules:
		if rule == null or rule.id == &"":
			errors.append("Rule has no id")
			continue
		if rule_ids.has(rule.id):
			errors.append("Duplicate rule id: %s" % String(rule.id))
		rule_ids[rule.id] = true
		if not [&"damage", &"status", &"material"].has(rule.trigger):
			errors.append("Unknown rule trigger: %s" % String(rule.id))
		if rule.trigger == &"damage" and not has_damage_type(rule.incoming):
			errors.append("Unknown rule damage type: %s" % String(rule.id))
		if rule.trigger == &"status" and rule.incoming != &"" and get_status(rule.incoming) == null:
			errors.append("Unknown rule status: %s" % String(rule.id))
		if rule.required_status != &"" and get_status(rule.required_status) == null:
			errors.append("Unknown required status: %s" % String(rule.id))
		if not _finite_nonnegative(rule.minimum_gauge):
			errors.append("Invalid minimum gauge: %s" % String(rule.id))
		if rule.actions.is_empty():
			errors.append("Rule has no actions: %s" % String(rule.id))
		for action in rule.actions:
			_validate_action(action, rule.id, errors)
	return errors


## Appends validation errors for one typed action and its referenced channels/statuses.
func _validate_action(action: ElementalAction, rule_id: StringName, errors: PackedStringArray) -> void:
	if action == null or action.kind < 0 or action.kind >= ElementalAction.Kind.size():
		errors.append("Invalid action kind: %s" % String(rule_id))
		return
	if not _finite_nonnegative(action.amount) or not _finite_nonnegative(action.scale) or not _finite_nonnegative(action.minimum) or not _finite_nonnegative(action.output_scale):
		errors.append("Invalid action magnitude: %s" % String(rule_id))
	match action.kind:
		ElementalAction.Kind.EXCHANGE:
			if get_status(action.status_id) == null or get_status(action.other_status) == null:
				errors.append("Invalid exchange status: %s" % String(rule_id))
			if action.output_status != &"" and get_status(action.output_status) == null:
				errors.append("Invalid exchange output: %s" % String(rule_id))
		ElementalAction.Kind.ADD_GAUGE, ElementalAction.Kind.REMOVE_GAUGE:
			if get_status(action.status_id) == null:
				errors.append("Invalid gauge status: %s" % String(rule_id))
		ElementalAction.Kind.DAMAGE:
			if not has_damage_type(action.damage_type):
				errors.append("Invalid action damage type: %s" % String(rule_id))
		ElementalAction.Kind.APPLY_EFFECT:
			if action.effect == null:
				errors.append("Missing action effect: %s" % String(rule_id))
		ElementalAction.Kind.SPAWN:
			if action.entity_id == &"":
				errors.append("Missing spawn entity id: %s" % String(rule_id))
		ElementalAction.Kind.TRANSFORM:
			if action.material_id == &"":
				errors.append("Missing transform material id: %s" % String(rule_id))
		ElementalAction.Kind.ADD_TAG, ElementalAction.Kind.REMOVE_TAG:
			if action.tag == &"":
				errors.append("Missing action tag: %s" % String(rule_id))


## Tests whether a damage channel is configured.
func has_damage_type(id: StringName) -> bool:
	return damage_types.has(id)


## Returns one immutable status definition or null.
func get_status(id: StringName) -> ElementalStatusDefinition:
	return statuses.get(id) as ElementalStatusDefinition


## Returns all status IDs affected by one damage channel in stable order.
func buildup_statuses(damage_type: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	var row: Dictionary = damage_buildup.get(damage_type, {})
	for id in row:
		result.append(StringName(id))
	result.sort()
	return result


## Reads the nonnegative buildup coefficient for one damage/status pair.
func get_buildup_rate(damage_type: StringName, status_id: StringName) -> float:
	var row: Dictionary = damage_buildup.get(damage_type, {})
	var value := float(row.get(status_id, 0.0))
	return value if _finite_nonnegative(value) else 0.0


## Returns the prototype multiplier for damage against one active status.
func get_damage_multiplier(damage_type: StringName, status_id: StringName) -> float:
	var row: Dictionary = damage_multipliers.get(damage_type, {})
	var value := float(row.get(status_id, 1.0))
	return value if _finite_nonnegative(value) else 1.0


## Multiplies all relevant status modifiers from an immutable active-status snapshot.
func get_combined_status_multiplier(damage_type: StringName, active_statuses: Array[StringName]) -> float:
	var result := 1.0
	for status_id in active_statuses:
		result *= get_damage_multiplier(damage_type, status_id)
	return result


## Maps the clamped resistance tier -1..4 to a signed damage multiplier.
func get_resistance_multiplier(tier: int) -> float:
	var value := float(resistance_multipliers.get(clampi(tier, -1, 4), 1.0))
	return value if _finite(value) else 1.0


## Reads a target-type base resistance, defaulting to zero for unspecified channels.
func get_base_resistance(target_type: StringName, damage_type: StringName) -> int:
	var row: Dictionary = base_resistances.get(target_type, {})
	return clampi(int(row.get(damage_type, 0)), -1, 4)


## Returns matching rules sorted by priority descending and id ascending.
func matching_rules(trigger: StringName, incoming: StringName, state: C_ElementalState) -> Array[ElementalRule]:
	var result: Array[ElementalRule] = []
	for rule in rules:
		if rule != null and rule.matches(trigger, incoming, state, self):
			result.append(rule)
	result.sort_custom(func(a: ElementalRule, b: ElementalRule) -> bool:
		if a.priority == b.priority:
			return String(a.id) < String(b.id)
		return a.priority > b.priority
	)
	return result


## Returns true for finite values, including signed resistance multipliers.
static func _finite(value: float) -> bool:
	return not is_nan(value) and not is_inf(value)


## Returns true for finite zero-or-positive magnitudes and coefficients.
static func _finite_nonnegative(value: float) -> bool:
	return value >= 0.0 and _finite(value)
