## Target classification, per-type base overrides and runtime resistance modifiers.
extends Component
class_name C_DamageResistances

@export var target_type: StringName = ElementalIds.TARGET_LIVING
var base_overrides: Array[ElementalResistanceValue] = []
var modifiers: Array[ElementalResistanceModifier] = []


## Creates a profile that inherits unspecified bases from the catalog target type.
func _init(initial_target_type: StringName = ElementalIds.TARGET_LIVING) -> void:
	target_type = initial_target_type


## Returns an individual base override or null when catalog base should be used.
func get_base_override(damage_type: StringName) -> ElementalResistanceValue:
	for value in base_overrides:
		if value.damage_type == damage_type:
			return value
	return null


## Sets or replaces one individual base resistance level.
func set_base_override(damage_type: StringName, level: int) -> void:
	var value := get_base_override(damage_type)
	if value == null:
		base_overrides.append(ElementalResistanceValue.new(damage_type, level))
	else:
		value.level = clampi(level, -1, 4)


## Replaces the modifier from the same source and damage type instead of stacking duplicates.
func set_modifier(damage_type: StringName, source_id: StringName, strength: int) -> void:
	for modifier in modifiers:
		if modifier.damage_type == damage_type and modifier.source_id == source_id:
			modifier.strength = strength
			return
	modifiers.append(ElementalResistanceModifier.new(damage_type, source_id, strength))


## Removes all resistance modifiers contributed by one stable source.
func remove_modifiers_from(source_id: StringName) -> void:
	for index in range(modifiers.size() - 1, -1, -1):
		if modifiers[index].source_id == source_id:
			modifiers.remove_at(index)
