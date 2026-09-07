## Material tags that let actors, cells, surfaces, zones and projectiles share reaction rules.
extends Component
class_name C_ReactiveMaterials

@export var material_ids: Array[StringName] = []


## Reports whether the subject currently exposes a material tag.
func has_material(material_id: StringName) -> bool:
	return material_id in material_ids


## Adds a material tag idempotently.
func add_material(material_id: StringName) -> void:
	if material_id != &"" and material_id not in material_ids:
		material_ids.append(material_id)


## Removes one material tag if present.
func remove_material(material_id: StringName) -> void:
	material_ids.erase(material_id)
