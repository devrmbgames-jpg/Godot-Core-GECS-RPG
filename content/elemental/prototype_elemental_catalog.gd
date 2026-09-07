## Factory for the prototype elemental rules requested by the design specification.
##
## The Dictionary shape intentionally resembles normalized CSV tables. Only
## ElementalCatalog parses these rows; gameplay code receives the typed catalog API.
extends RefCounted
class_name PrototypeElementalCatalog


## Creates a fresh validated typed catalog from prototype rows.
static func create() -> ElementalCatalog:
	return ElementalCatalog.from_dictionary(_data())


## Returns the raw prototype document at the storage-adapter boundary.
static func _data() -> Dictionary:
	return {
		"damage_types": [
			{"id": "physical"},
			{"id": "fire", "buildup_status": "burning", "buildup_per_damage": 1.0},
			{"id": "ice", "buildup_status": "cold", "buildup_per_damage": 1.0},
			{"id": "electric", "buildup_status": "electrified", "buildup_per_damage": 1.0},
			{"id": "positive"},
			{"id": "negative"},
			{"id": "poison", "buildup_status": "poisoned", "buildup_per_damage": 1.0},
			{"id": "acid"},
		],
		"statuses": [
			{
				"id": "burning", "activation_threshold": 30.0, "deactivation_threshold": 10.0,
				"max_buildup": 100.0, "duration": 8.0, "decay_per_second": 5.0,
			},
			{
				"id": "cold", "activation_threshold": 25.0, "deactivation_threshold": 10.0,
				"max_buildup": 100.0, "duration": 6.0, "decay_per_second": 4.0,
			},
			{
				"id": "frozen", "activation_threshold": 50.0, "deactivation_threshold": 5.0,
				"max_buildup": 100.0, "duration": 4.0, "decay_per_second": 10.0,
			},
			{
				"id": "wet", "activation_threshold": 20.0, "deactivation_threshold": 5.0,
				"max_buildup": 100.0, "duration": 8.0, "decay_per_second": 3.0,
			},
			{
				"id": "electrified", "activation_threshold": 25.0, "deactivation_threshold": 5.0,
				"max_buildup": 100.0, "duration": 3.0, "decay_per_second": 8.0,
			},
			{
				"id": "poisoned", "activation_threshold": 20.0, "deactivation_threshold": 5.0,
				"max_buildup": 100.0, "duration": 10.0, "decay_per_second": 2.0,
			},
		],
		"damage_multipliers": [
			{"damage_type": "fire", "status": "burning", "multiplier": 1.2},
			{"damage_type": "fire", "status": "wet", "multiplier": 0.8},
			{"damage_type": "fire", "status": "cold", "multiplier": 0.65},
			{"damage_type": "fire", "status": "frozen", "multiplier": 0.4},
			{"damage_type": "ice", "status": "wet", "multiplier": 1.2},
			{"damage_type": "ice", "status": "frozen", "multiplier": 1.25},
			{"damage_type": "ice", "status": "cold", "multiplier": 1.5},
			{"damage_type": "physical", "status": "frozen", "multiplier": 2.5},
			{"damage_type": "electric", "status": "wet", "multiplier": 1.5},
			{"damage_type": "electric", "status": "electrified", "multiplier": 1.2},
		],
		"resistance_levels": [
			{"level": -1, "multiplier": 2.0},
			{"level": 0, "multiplier": 1.0},
			{"level": 1, "multiplier": 0.5},
			{"level": 2, "multiplier": 0.0},
			{"level": 3, "multiplier": -0.5},
			{"level": 4, "multiplier": -1.0},
		],
		"target_resistances": [
			{"target_type": "living", "base": {"negative": -1, "positive": 4}},
			{"target_type": "construct", "base": {"negative": 2, "positive": 2}},
			{"target_type": "undead", "base": {"positive": -1, "negative": 4}},
		],
		"reactions": [
			{
				"id": "fire_quenches_wet", "trigger": "damage_status",
				"first": "fire", "second": "wet", "priority": 100,
				"actions": [
					{"kind": "modify_status", "status": "wet", "amount": -1.0, "scale_with_power": true},
					{"kind": "spawn_entity", "semantic_id": "wet_mist_zone"},
				],
			},
			{
				"id": "burning_meets_cold", "trigger": "status_status",
				"first": "burning", "second": "cold", "priority": 90, "order_independent": true,
				"actions": [
					{"kind": "modify_status", "status": "burning", "amount": -1.0, "scale_with_power": true},
					{"kind": "modify_status", "status": "cold", "amount": -1.0, "scale_with_power": true},
					{"kind": "apply_status", "status": "wet", "amount": 1.0, "scale_with_power": true},
				],
			},
			{
				"id": "burning_evaporates_wet", "trigger": "status_status",
				"first": "burning", "second": "wet", "priority": 100, "order_independent": true,
				"actions": [
					{"kind": "modify_status", "status": "burning", "amount": -1.0, "scale_with_power": true},
					{"kind": "modify_status", "status": "wet", "amount": -1.0, "scale_with_power": true},
				],
			},
			{
				"id": "burning_thaws_frozen", "trigger": "status_status",
				"first": "burning", "second": "frozen", "priority": 110, "order_independent": true,
				"actions": [
					{"kind": "modify_status", "status": "burning", "amount": -1.0, "scale_with_power": true},
					{"kind": "modify_status", "status": "frozen", "amount": -1.0, "scale_with_power": true},
					{"kind": "apply_status", "status": "wet", "amount": 1.0, "scale_with_power": true},
				],
			},
			{
				"id": "wet_freezes_with_cold", "trigger": "status_status",
				"first": "wet", "second": "cold", "priority": 80, "order_independent": true,
				"actions": [
					{"kind": "modify_status", "status": "wet", "amount": -1.0, "scale_with_power": true},
					{"kind": "modify_status", "status": "cold", "amount": -1.0, "scale_with_power": true},
					{"kind": "apply_status", "status": "frozen", "amount": 2.0, "scale_with_power": true},
				],
			},
			{
				"id": "electric_charges_water", "trigger": "damage_material",
				"first": "electric", "second": "water", "priority": 100,
				"actions": [
					{"kind": "transform_surface", "semantic_id": "electrified_water"},
					{"kind": "emit_effect", "semantic_id": "water_chain_electricity"},
				],
			},
			{
				"id": "electric_overload", "trigger": "damage_status",
				"first": "electric", "second": "electrified", "priority": 80,
				"actions": [
					{"kind": "deal_damage", "damage_type": "electric", "amount": 0.25, "scale_with_power": true},
					{"kind": "emit_effect", "semantic_id": "electric_overload"},
				],
			},
			{
				"id": "poison_cloud_from_material", "trigger": "damage_material",
				"first": "poison", "second": "poison_material", "priority": 60,
				"actions": [
					{"kind": "spawn_entity", "semantic_id": "poison_cloud"},
				],
			},
			{
				"id": "fire_melts_earth", "trigger": "damage_material",
				"first": "fire", "second": "earth", "priority": 50,
				"actions": [
					{"kind": "transform_surface", "semantic_id": "lava"},
				],
			},
		],
	}
