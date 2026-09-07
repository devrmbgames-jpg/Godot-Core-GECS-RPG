## Data boundary for elemental prototype tables. Gameplay code queries this API instead of raw Dictionaries.
extends Resource
class_name ElementalCatalog

var damage_types: Array[StringName] = []
var statuses: Dictionary = {}
var damage_buildup: Dictionary = {}
var damage_multipliers: Dictionary = {}
var resistance_multipliers: Dictionary = {}
var base_resistances: Dictionary = {}
var rules: Array[ElementalRule] = []


## Returns one status definition or null when the id is unknown.
func get_status(id: StringName) -> ElementalStatusDefinition:
	return statuses.get(id) as ElementalStatusDefinition


## Returns status buildup per one point of incoming impact for a damage type.
func get_damage_buildup(damage_type: StringName) -> Dictionary:
	return damage_buildup.get(damage_type, {}) as Dictionary


## Returns the prototype multiplier for damage against one active status.
func get_damage_multiplier(damage_type: StringName, status_id: StringName) -> float:
	var row: Dictionary = damage_multipliers.get(damage_type, {}) as Dictionary
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
	var row: Dictionary = base_resistances.get(target_type, {}) as Dictionary
	return int(row.get(damage_type, 0))


## Returns matching rules sorted by priority descending and id ascending for deterministic resolution.
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
