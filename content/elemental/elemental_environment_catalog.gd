## Storage-neutral adapter for material and spawn profiles. Gameplay never reads raw environment rows.
extends Resource
class_name ElementalEnvironmentCatalog

var definitions: Dictionary = {}


## Converts Dictionary rows to reusable typed material/zone definitions; a CSV reader can produce the same rows.
static func from_tables(tables: Dictionary) -> ElementalEnvironmentCatalog:
	var catalog := ElementalEnvironmentCatalog.new()
	for id in tables:
		var row: Dictionary = tables[id]
		var definition := ElementalEnvironmentDefinition.new()
		definition.id = StringName(id)
		definition.material_id = StringName(row.get("material_id", id))
		for tag in row.get("tags", []):
			definition.tags.append(StringName(tag))
		definition.scene = row.get("scene") as PackedScene
		definition.radius = float(row.get("radius", 2.0))
		definition.duration = float(row.get("duration", 0.0))
		definition.tick_interval = float(row.get("tick_interval", 1.0))
		definition.damage_type = StringName(row.get("damage_type", "PHYSICAL"))
		definition.damage_amount = float(row.get("damage_amount", 0.0))
		definition.buildup_scale = float(row.get("buildup_scale", 1.0))
		definition.affects_all = bool(row.get("affects_all", true))
		for status_row in row.get("status_applications", []):
			definition.status_applications.append(ElementalStatusApplication.new(StringName(status_row.get("status_id", "")), float(status_row.get("amount", 0.0))))
		catalog.definitions[definition.id] = definition
	return catalog


## Returns one typed material or spawn profile, or null for an unknown ID.
func get_definition(id: StringName) -> ElementalEnvironmentDefinition:
	return definitions.get(id) as ElementalEnvironmentDefinition


## Reports invalid profiles and unknown damage/status references before gameplay starts.
func validate(elements: ElementalCatalog) -> PackedStringArray:
	var errors := PackedStringArray()
	for id in definitions:
		var definition := get_definition(StringName(id))
		if definition == null or not definition.is_valid_definition():
			errors.append("Invalid environment profile: %s" % String(id))
			continue
		if definition.damage_amount > 0.0 and not elements.has_damage_type(definition.damage_type):
			errors.append("Unknown environment damage type: %s" % String(id))
		for application in definition.status_applications:
			if elements.get_status(application.status_id) == null:
				errors.append("Unknown environment status: %s" % String(application.status_id))
	return errors
