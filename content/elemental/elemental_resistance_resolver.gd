## Pure resistance calculation shared by damage observers and tests.
extends RefCounted
class_name ElementalResistanceResolver


## Resolves base + strongest negative + strongest positive, then clamps to -1...+4.
## Active status modifiers participate by value but never alter status immunity.
static func get_final_resistance(
	profile: C_DamageResistances,
	state: C_ElementalState,
	catalog: ElementalCatalog,
	damage_type: StringName,
) -> int:
	if catalog == null:
		return 0
	var base := 0
	if profile != null:
		var override := profile.get_base_override(damage_type)
		base = override.level if override != null else catalog.get_base_resistance(profile.target_type, damage_type)
	var strongest_negative := 0
	var strongest_positive := 0
	if profile != null:
		for modifier in profile.modifiers:
			if modifier.damage_type == damage_type:
				strongest_negative = mini(strongest_negative, modifier.strength)
				strongest_positive = maxi(strongest_positive, modifier.strength)
	if state != null:
		for status in state.statuses:
			if not status.active or status.definition == null:
				continue
			for modifier in status.definition.resistance_modifiers:
				if modifier.damage_type == damage_type:
					strongest_negative = mini(strongest_negative, modifier.strength)
					strongest_positive = maxi(strongest_positive, modifier.strength)
	return clampi(base + strongest_negative + strongest_positive, -1, 4)


## Returns the catalog multiplier for the fully resolved resistance level.
static func get_damage_multiplier(
	profile: C_DamageResistances,
	state: C_ElementalState,
	catalog: ElementalCatalog,
	damage_type: StringName,
) -> float:
	return catalog.get_resistance_multiplier(get_final_resistance(profile, state, catalog, damage_type))
