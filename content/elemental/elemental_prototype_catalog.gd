## Builds the prototype elemental catalog from Dictionaries behind the typed ElementalCatalog API.
extends RefCounted
class_name ElementalPrototypeCatalog


## Creates a fresh immutable-by-convention prototype catalog.
static func build() -> ElementalCatalog:
	var catalog := ElementalCatalog.new()
	catalog.damage_types = [&"PHYSICAL", &"FIRE", &"ICE", &"ELECTRIC", &"POSITIVE", &"NEGATIVE", &"POISON", &"ACID"]
	catalog.resistance_multipliers = {-1: 2.0, 0: 1.0, 1: 0.5, 2: 0.0, 3: -0.5, 4: -1.0}
	catalog.base_resistances = {
		&"living": {&"NEGATIVE": -1, &"POSITIVE": 4},
		&"construct": {&"NEGATIVE": 2, &"POSITIVE": 2},
		&"undead": {&"POSITIVE": -1, &"NEGATIVE": 4},
	}
	catalog.damage_buildup = {
		&"FIRE": {&"BURNING": 1.0},
		&"ICE": {&"COLD": 1.0},
		&"ELECTRIC": {&"ELECTRIFIED": 1.0},
		&"POISON": {&"POISONED": 1.0},
	}
	catalog.damage_multipliers = {
		&"FIRE": {&"BURNING": 1.2, &"WET": 0.8, &"COLD": 0.65, &"FROZEN": 0.4},
		&"ICE": {&"WET": 1.2, &"FROZEN": 1.25, &"COLD": 1.5},
		&"PHYSICAL": {&"FROZEN": 2.5},
		&"ELECTRIC": {&"WET": 1.5, &"ELECTRIFIED": 1.2},
	}
	for status_id in [&"BURNING", &"COLD", &"FROZEN", &"WET", &"ELECTRIFIED", &"POISONED"]:
		catalog.statuses[status_id] = _status(status_id)
	catalog.rules = _rules()
	return catalog


## Creates one prototype status gauge definition.
static func _status(id: StringName) -> ElementalStatusDefinition:
	var definition := ElementalStatusDefinition.new()
	definition.id = id
	definition.threshold = 20.0
	definition.max_gauge = 200.0
	definition.duration = 8.0
	definition.decay_per_second = 0.0
	return definition


## Creates deterministic prototype reaction rules.
static func _rules() -> Array[ElementalRule]:
	return [
		_pair(&"burning_cold_to_wet", &"BURNING", &"COLD", &"WET", 100),
		_pair(&"burning_frozen_to_wet", &"BURNING", &"FROZEN", &"WET", 110),
		_pair(&"burning_wet_cancel", &"BURNING", &"WET", &"", 120),
		_pair(&"wet_cold_to_frozen", &"WET", &"COLD", &"FROZEN", 90),
		_environment_electric_water(),
		_environment_fire_wet_fog(),
		_environment_poison_cloud(),
		_environment_earth_fire_lava(),
	]


## Creates a symmetric gauge-exchange status rule; output receives consumed opposing strength.
static func _pair(id: StringName, incoming: StringName, required: StringName, output: StringName, priority: int) -> ElementalRule:
	var action := ElementalAction.new()
	action.kind = ElementalAction.Kind.EXCHANGE
	action.status_id = incoming
	action.other_status = required
	action.output_status = output
	action.output_scale = 1.0
	var rule := ElementalRule.new()
	rule.id = id
	rule.trigger = &"status"
	rule.incoming = incoming
	rule.required_status = required
	rule.priority = priority
	rule.actions = [action]
	return rule


## ELECTRIC impact on a water-tagged target converts its material state to electrified water.
static func _environment_electric_water() -> ElementalRule:
	var action := ElementalAction.new()
	action.kind = ElementalAction.Kind.TRANSFORM
	action.material_id = &"electrified_water"
	var rule := ElementalRule.new()
	rule.id = &"electric_water"
	rule.trigger = &"damage"
	rule.incoming = &"ELECTRIC"
	rule.required_tag = &"water"
	rule.priority = 200
	rule.actions = [action]
	return rule


## FIRE impact against accumulated WET consumes impact-matched wet strength and requests wet fog spawn.
static func _environment_fire_wet_fog() -> ElementalRule:
	var remove := ElementalAction.new()
	remove.kind = ElementalAction.Kind.REMOVE_GAUGE
	remove.status_id = &"WET"
	remove.use_impact = true
	var spawn := ElementalAction.new()
	spawn.kind = ElementalAction.Kind.SPAWN
	spawn.entity_id = &"wet_fog"
	var rule := ElementalRule.new()
	rule.id = &"fire_wet_fog"
	rule.trigger = &"damage"
	rule.incoming = &"FIRE"
	rule.required_status = &"WET"
	rule.priority = 180
	rule.actions = [remove, spawn]
	return rule


## POISON impact on a poison-reactive surface requests a poison cloud entity.
static func _environment_poison_cloud() -> ElementalRule:
	var spawn := ElementalAction.new()
	spawn.kind = ElementalAction.Kind.SPAWN
	spawn.entity_id = &"poison_cloud"
	var rule := ElementalRule.new()
	rule.id = &"poison_cloud"
	rule.trigger = &"damage"
	rule.incoming = &"POISON"
	rule.required_tag = &"poison_reactive"
	rule.priority = 80
	rule.actions = [spawn]
	return rule


## FIRE impact on an earth-tagged surface transforms it to lava.
static func _environment_earth_fire_lava() -> ElementalRule:
	var action := ElementalAction.new()
	action.kind = ElementalAction.Kind.TRANSFORM
	action.material_id = &"lava"
	var rule := ElementalRule.new()
	rule.id = &"earth_fire_lava"
	rule.trigger = &"damage"
	rule.incoming = &"FIRE"
	rule.required_tag = &"earth"
	rule.priority = 70
	rule.actions = [action]
	return rule
