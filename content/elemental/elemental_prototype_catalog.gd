## Dictionary-based prototype content loaded exclusively through ElementalCatalog's typed adapter.
## Future CSV import only needs to produce the same storage-neutral rows.
extends RefCounted
class_name ElementalPrototypeCatalog


## Creates the prototype catalog, then attaches reusable status effects before validation/use.
static func build() -> ElementalCatalog:
	var catalog := ElementalCatalog.from_tables(_tables())
	var burning := catalog.get_status(&"BURNING")
	if burning != null:
		burning.effect = DemoEffectCatalog.burning()
	var poisoned := catalog.get_status(&"POISONED")
	if poisoned != null:
		poisoned.effect = DemoEffectCatalog.poison()
	return catalog


## Returns the complete prototype schema for damage, buildup, multipliers, resistances and reactions.
static func _tables() -> Dictionary:
	return {
		"damage_types": [&"PHYSICAL", &"FIRE", &"ICE", &"ELECTRIC", &"POSITIVE", &"NEGATIVE", &"POISON", &"ACID"],
		"statuses": {
			&"BURNING": _status_row(),
			&"COLD": _status_row(),
			&"FROZEN": _status_row(),
			&"WET": _status_row(),
			&"ELECTRIFIED": _status_row(),
			&"POISONED": _status_row(),
		},
		"damage_buildup": {
			&"FIRE": {&"BURNING": 1.0},
			&"ICE": {&"COLD": 1.0},
			&"ELECTRIC": {&"ELECTRIFIED": 1.0},
			&"POISON": {&"POISONED": 1.0},
		},
		"damage_multipliers": {
			&"FIRE": {&"BURNING": 1.2, &"WET": 0.8, &"COLD": 0.65, &"FROZEN": 0.4},
			&"ICE": {&"WET": 1.2, &"FROZEN": 1.25, &"COLD": 1.5},
			&"PHYSICAL": {&"FROZEN": 2.5},
			&"ELECTRIC": {&"WET": 1.5, &"ELECTRIFIED": 1.2},
		},
		"resistance_multipliers": {-1: 2.0, 0: 1.0, 1: 0.5, 2: 0.0, 3: -0.5, 4: -1.0},
		"base_resistances": {
			&"living": {&"NEGATIVE": -1, &"POSITIVE": 4},
			&"construct": {&"NEGATIVE": 2, &"POSITIVE": 2},
			&"undead": {&"POSITIVE": -1, &"NEGATIVE": 4},
		},
		"rules": [
			_pair_row(&"burning_wet_cancel", &"BURNING", &"WET", &"", 120),
			_pair_row(&"burning_frozen_to_wet", &"BURNING", &"FROZEN", &"WET", 110),
			_pair_row(&"burning_cold_to_wet", &"BURNING", &"COLD", &"WET", 100),
			_pair_row(&"wet_cold_to_frozen", &"WET", &"COLD", &"FROZEN", 90),
			{
				"id": &"electric_water", "trigger": &"damage", "incoming": &"ELECTRIC", "required_tag": &"water", "priority": 200,
				"actions": [{"kind": "TRANSFORM", "material_id": &"electrified_water"}],
			},
			{
				"id": &"fire_wet_fog", "trigger": &"damage", "incoming": &"FIRE", "required_status": &"WET", "minimum_gauge": 0.0001, "priority": 180,
				"actions": [
					{"kind": "REMOVE_GAUGE", "status_id": &"WET", "use_impact": true, "minimum": 0.0001},
					{"kind": "SPAWN", "entity_id": &"wet_fog"},
				],
			},
			{
				"id": &"poison_cloud", "trigger": &"damage", "incoming": &"POISON", "required_tag": &"poison_reactive", "priority": 80,
				"actions": [{"kind": "SPAWN", "entity_id": &"poison_cloud"}],
			},
			{
				"id": &"earth_fire_lava", "trigger": &"damage", "incoming": &"FIRE", "required_tag": &"earth", "priority": 70,
				"actions": [{"kind": "TRANSFORM", "material_id": &"lava"}],
			},
		],
	}


## Creates common threshold/lifetime values for the six prototype statuses.
static func _status_row() -> Dictionary:
	return {"threshold": 20.0, "max_gauge": 200.0, "duration": 8.0, "decay_per_second": 0.0}


## Creates a symmetric status-pair exchange row; residual strength remains on the stronger gauge.
static func _pair_row(id: StringName, incoming: StringName, required: StringName, output: StringName, priority: int) -> Dictionary:
	return {
		"id": id,
		"trigger": &"status",
		"incoming": incoming,
		"required_status": required,
		"priority": priority,
		"actions": [{
			"kind": "EXCHANGE",
			"status_id": incoming,
			"other_status": required,
			"output_status": output,
			"output_scale": 1.0,
		}],
	}
