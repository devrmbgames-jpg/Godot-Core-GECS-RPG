## Dictionary-based prototype environment content, independent of the resolver and scene implementation.
extends RefCounted
class_name ElementalPrototypeEnvironment


## Builds reusable material and zone profiles from storage-neutral rows.
static func build() -> ElementalEnvironmentCatalog:
	return ElementalEnvironmentCatalog.from_tables({
		&"water": {
			"tags": [&"water", &"liquid", &"conductive"],
			"radius": 2.0, "tick_interval": 1.0,
			"status_applications": [{"status_id": &"WET", "amount": 20.0}],
		},
		&"electrified_water": {
			"tags": [&"water", &"liquid", &"conductive"],
			"radius": 2.0, "tick_interval": 1.0,
			"damage_type": &"ELECTRIC", "damage_amount": 3.0,
			"status_applications": [{"status_id": &"WET", "amount": 20.0}],
		},
		&"earth": {
			"tags": [&"earth", &"solid"], "radius": 2.0,
		},
		&"lava": {
			"tags": [&"lava", &"hot", &"liquid"],
			"radius": 2.0, "tick_interval": 1.0,
			"damage_type": &"FIRE", "damage_amount": 5.0,
		},
		&"wet_fog": {
			"tags": [&"water", &"cloud", &"mist"],
			"radius": 2.5, "duration": 6.0, "tick_interval": 1.0,
			"status_applications": [{"status_id": &"WET", "amount": 20.0}],
		},
		&"poison_cloud": {
			"tags": [&"cloud", &"poison_reactive"],
			"radius": 2.5, "duration": 8.0, "tick_interval": 1.0,
			"damage_type": &"POISON", "damage_amount": 2.0,
		},
	})
