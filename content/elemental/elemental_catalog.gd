## Typed read-only API over prototype Dictionary data and future CSV rows.
##
## Raw Dictionary access is intentionally confined to construction helpers in this file.
## Resolver, components and game code consume typed definitions and query methods only.
extends RefCounted
class_name ElementalCatalog

var _damage_types: Dictionary = {}
var _statuses: Dictionary = {}
var _multipliers: Dictionary = {}
var _resistance_levels: Dictionary = {}
var _target_resistances: Dictionary = {}
var _reactions: Array[ElementalReactionDefinition] = []
var _validation_errors: PackedStringArray = PackedStringArray()


## Builds a typed catalog from a prototype document or a normalized CSV import document.
static func from_dictionary(data: Dictionary) -> ElementalCatalog:
	var catalog := ElementalCatalog.new()
	catalog._read_damage_types(data.get("damage_types", []))
	catalog._read_statuses(data.get("statuses", []))
	catalog._read_multipliers(data.get("damage_multipliers", []))
	catalog._read_resistances(data.get("resistance_levels", []), data.get("target_resistances", []))
	catalog._read_reactions(data.get("reactions", []))
	catalog._validate_references()
	return catalog


## Returns a damage definition or null for an unknown open ID.
func get_damage_type(damage_type: StringName) -> ElementalDamageDefinition:
	return _damage_types.get(damage_type) as ElementalDamageDefinition


## Returns a status definition or null for an unknown open ID.
func get_status(status_id: StringName) -> ElementalStatusDefinition:
	return _statuses.get(status_id) as ElementalStatusDefinition


## Returns the configured damage/status multiplier, defaulting to neutral 1.0.
func get_damage_multiplier(damage_type: StringName, status_id: StringName) -> float:
	return float(_multipliers.get(_pair_key(damage_type, status_id), 1.0))


## Returns the target-type base resistance level, defaulting to zero.
func get_base_resistance(target_type: StringName, damage_type: StringName) -> int:
	var values: Dictionary = _target_resistances.get(target_type, {})
	return int(values.get(damage_type, 0))


## Converts a clamped resistance level to a health-damage multiplier.
func get_resistance_multiplier(level: int) -> float:
	return float(_resistance_levels.get(clampi(level, -1, 4), 1.0))


## Returns priority-sorted reaction definitions matching a typed pair.
func get_reactions(
	trigger_kind: ElementalReactionDefinition.TriggerKind,
	first_id: StringName,
	second_id: StringName,
) -> Array[ElementalReactionDefinition]:
	var result: Array[ElementalReactionDefinition] = []
	for reaction in _reactions:
		if reaction.matches(trigger_kind, first_id, second_id):
			result.append(reaction)
	result.sort_custom(_sort_reactions)
	return result


## Returns construction/validation errors without exposing catalog tables.
func get_validation_errors() -> PackedStringArray:
	return _validation_errors.duplicate()


## Reads damage definition rows from the external data boundary.
func _read_damage_types(rows: Variant) -> void:
	if not rows is Array:
		_validation_errors.append("damage_types must be an Array")
		return
	for row_value in rows:
		if not row_value is Dictionary:
			_validation_errors.append("damage_types row must be a Dictionary")
			continue
		var row: Dictionary = row_value
		var definition := ElementalDamageDefinition.new(
			StringName(row.get("id", "")),
			StringName(row.get("buildup_status", "")),
			float(row.get("buildup_per_damage", 0.0)),
		)
		if definition.id == &"" or _damage_types.has(definition.id):
			_validation_errors.append("invalid or duplicate damage type: %s" % String(definition.id))
			continue
		_damage_types[definition.id] = definition


## Reads status definition rows and nested resistance modifier rows.
func _read_statuses(rows: Variant) -> void:
	if not rows is Array:
		_validation_errors.append("statuses must be an Array")
		return
	for row_value in rows:
		if not row_value is Dictionary:
			_validation_errors.append("statuses row must be a Dictionary")
			continue
		var row: Dictionary = row_value
		var definition := ElementalStatusDefinition.new(
			StringName(row.get("id", "")),
			float(row.get("activation_threshold", 1.0)),
			float(row.get("deactivation_threshold", 0.0)),
			float(row.get("max_buildup", 100.0)),
			float(row.get("duration", 0.0)),
			float(row.get("decay_per_second", 0.0)),
		)
		for modifier_value in row.get("resistance_modifiers", []):
			if not modifier_value is Dictionary:
				continue
			var modifier_row: Dictionary = modifier_value
			definition.resistance_modifiers.append(ElementalResistanceModifierDefinition.new(
				StringName(modifier_row.get("damage_type", "")),
				int(modifier_row.get("strength", 0)),
			))
		if definition.id == &"" or _statuses.has(definition.id):
			_validation_errors.append("invalid or duplicate status: %s" % String(definition.id))
			continue
		if definition.deactivation_threshold >= definition.activation_threshold:
			_validation_errors.append("status %s requires deactivation_threshold < activation_threshold" % String(definition.id))
		_statuses[definition.id] = definition


## Reads sparse damage/status multiplier rows.
func _read_multipliers(rows: Variant) -> void:
	if not rows is Array:
		_validation_errors.append("damage_multipliers must be an Array")
		return
	for row_value in rows:
		if not row_value is Dictionary:
			continue
		var row: Dictionary = row_value
		var damage_type := StringName(row.get("damage_type", ""))
		var status_id := StringName(row.get("status", ""))
		_multipliers[_pair_key(damage_type, status_id)] = float(row.get("multiplier", 1.0))


## Reads resistance level mapping and per-target-type base tables.
func _read_resistances(level_rows: Variant, target_rows: Variant) -> void:
	if level_rows is Array:
		for row_value in level_rows:
			if row_value is Dictionary:
				var row: Dictionary = row_value
				_resistance_levels[int(row.get("level", 0))] = float(row.get("multiplier", 1.0))
	if target_rows is Array:
		for row_value in target_rows:
			if not row_value is Dictionary:
				continue
			var row: Dictionary = row_value
			var values: Dictionary = {}
			var base_value: Variant = row.get("base", {})
			if base_value is Dictionary:
				for damage_key in base_value:
					values[StringName(damage_key)] = int(base_value[damage_key])
			_target_resistances[StringName(row.get("target_type", ""))] = values


## Reads typed reaction definitions and their ordered action lists.
func _read_reactions(rows: Variant) -> void:
	if not rows is Array:
		_validation_errors.append("reactions must be an Array")
		return
	for row_value in rows:
		if not row_value is Dictionary:
			continue
		var row: Dictionary = row_value
		var reaction := ElementalReactionDefinition.new()
		reaction.id = StringName(row.get("id", ""))
		reaction.trigger_kind = _parse_trigger_kind(StringName(row.get("trigger", "damage_status")))
		reaction.first_id = StringName(row.get("first", ""))
		reaction.second_id = StringName(row.get("second", ""))
		reaction.priority = int(row.get("priority", 0))
		reaction.order_independent = bool(row.get("order_independent", false))
		for action_value in row.get("actions", []):
			if action_value is Dictionary:
				reaction.actions.append(_parse_action(action_value))
		_reactions.append(reaction)


## Converts an external trigger name to the closed set of resolver trigger behaviors.
func _parse_trigger_kind(value: StringName) -> ElementalReactionDefinition.TriggerKind:
	match value:
		&"status_status":
			return ElementalReactionDefinition.TriggerKind.STATUS_STATUS
		&"damage_material":
			return ElementalReactionDefinition.TriggerKind.DAMAGE_MATERIAL
		_:
			return ElementalReactionDefinition.TriggerKind.DAMAGE_STATUS


## Converts one raw action row into an immutable typed action definition.
func _parse_action(row: Dictionary) -> ElementalReactionActionDefinition:
	var action := ElementalReactionActionDefinition.new()
	action.kind = _parse_action_kind(StringName(row.get("kind", "modify_status")))
	action.status_id = StringName(row.get("status", ""))
	action.damage_type = StringName(row.get("damage_type", ""))
	action.semantic_id = StringName(row.get("semantic_id", ""))
	action.amount = float(row.get("amount", 0.0))
	action.scale_with_reaction_power = bool(row.get("scale_with_power", false))
	return action


## Converts an external action name to behavior implemented by ElementalActionExecutor.
func _parse_action_kind(value: StringName) -> ElementalReactionActionDefinition.Kind:
	match value:
		&"apply_status": return ElementalReactionActionDefinition.Kind.APPLY_STATUS
		&"remove_status": return ElementalReactionActionDefinition.Kind.REMOVE_STATUS
		&"deal_damage": return ElementalReactionActionDefinition.Kind.DEAL_DAMAGE
		&"spawn_entity": return ElementalReactionActionDefinition.Kind.SPAWN_ENTITY
		&"transform_surface": return ElementalReactionActionDefinition.Kind.TRANSFORM_SURFACE
		&"add_material": return ElementalReactionActionDefinition.Kind.ADD_MATERIAL
		&"remove_material": return ElementalReactionActionDefinition.Kind.REMOVE_MATERIAL
		&"emit_effect": return ElementalReactionActionDefinition.Kind.EMIT_EFFECT
		_: return ElementalReactionActionDefinition.Kind.MODIFY_STATUS


## Validates cross-references while preserving open IDs for future data additions.
func _validate_references() -> void:
	for definition_value in _damage_types.values():
		var definition := definition_value as ElementalDamageDefinition
		if definition.buildup_status_id != &"" and not _statuses.has(definition.buildup_status_id):
			_validation_errors.append("damage %s references unknown status %s" % [definition.id, definition.buildup_status_id])
	for level in [-1, 0, 1, 2, 3, 4]:
		if not _resistance_levels.has(level):
			_validation_errors.append("missing resistance multiplier for level %d" % level)


## Builds an internal collision-safe key for a sparse two-dimensional table.
func _pair_key(first_id: StringName, second_id: StringName) -> String:
	return "%s\u001f%s" % [String(first_id), String(second_id)]


## Sorts reactions by descending priority and stable ID for deterministic resolution.
func _sort_reactions(left: ElementalReactionDefinition, right: ElementalReactionDefinition) -> bool:
	if left.priority != right.priority:
		return left.priority > right.priority
	return String(left.id) < String(right.id)
