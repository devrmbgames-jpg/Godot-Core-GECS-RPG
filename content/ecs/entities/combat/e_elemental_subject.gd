## Reusable no-Health reaction subject for cells, zones, clouds and surfaces.
@tool
extends Entity
class_name E_ElementalSubject

@export var target_type: StringName = ElementalIds.TARGET_CONSTRUCT
@export var material_ids: Array[StringName] = []
@export var status_immunity_ids: Array[StringName] = []


## Creates isolated runtime components from editor-configured design snapshots.
func define_components() -> Array:
	var materials := C_ReactiveMaterials.new()
	materials.material_ids.append_array(material_ids)
	var immunities := C_StatusImmunities.new()
	immunities.status_ids.append_array(status_immunity_ids)
	return [
		C_ElementalState.new(),
		C_DamageResistances.new(target_type),
		immunities,
		materials,
	]
