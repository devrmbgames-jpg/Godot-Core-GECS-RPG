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
		catalog.damage_types.append(StringName(id))
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


## Converts one storage action to a typed instruction; symbolic or integer kinds are accepted.
static func _action_from_row(row: Dictionary) -> ElementalAction:
	var action := ElementalAction.new()
	var raw_kind: Variant = row.get("kind", "ADD_GAUGE")
	if raw_kind is String or raw_kind is StringName:
		action.kind = int(ElementalAction.Kind.get(String(raw_kind).to_upper(), -1)) as ElementalAction.Kind
	else:
		action.kind = int(raw_kind) as ElementalAction.Kind
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


## Reports invalid definitions and references before a catalog is used in gameplay.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	for id in statuses:
		var definition := get_status(StringName(id))
		if definition == null or not definition.is_valid_definition():
			errors.append("Invalid status: %s" % String(id))
	for damage_type in damage_buildup:
		if not has_damage_type(StringName(damage_type)):
			errors.append("Unknown buildup damage type: %s" % String(damage_type))
		var row: Dictionary = damage_buildup[damage_type]
		for status_id in row:
			if get_status(StringName(status_id)) == null:
				errors.append("Unknown buildup status: %s" % String(status_id))
	for rule in rules:
		if rule == null or rule.id == &"":
			errors.append("Rule has no id")
			continue
		if rule.trigger == &"damage" and not has_damage_type(rule.incoming):
			errors.append("Unknown rule damage type: %s" % String(rule.id))
		if rule.trigger == &"status" and get_status(rule.incoming) == null:
			errors.append("Unknown rule status: %s" % String(rule.id))
		if rule.required_status != &"" and get_status(rule.required_status) == null:
			errors.append("Unknown required status: %s" % String(rule.id))
	return errors


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
	return maxf(0.0, float(row.get(status_id, 0.0)))


## Returns the prototype multiplier for damage against one active status.
func get_damage_multiplier(damage_type: StringName, status_id: StringName) -> float:
	var row: Dictionary = damage_multipliers.get(damage_type, {})
	return float(row.get(status_id, 1.0))


## Multiplies all relevant status modifiers from an immutable active-status snapshot.
func get_combined_status_multiplier(damage_type: StringName, active_statuses: Array[StringName]) -> float:
	var result := 1.0
	for status_id in active_statuses:
		result *= get_damage_multiplier(damage_type, status_id)
	return result


## Maps the clamped resistance tier -1..4 to a signed damage multiplier.
func get_resistance_multiplier(tier: int) -> float:
	return float(resistance_multipliers.get(clampi(tier, -1, 4), 1.0))


## Reads a target-type base resistance, defaulting to zero for unspecified channels.
func get_base_resistance(target_type: StringName, damage_type: StringName) -> int:
	var row: Dictionary = base_resistances.get(target_type, {})
	return int(row.get(damage_type, 0))


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
