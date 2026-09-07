## Source-level executable scenario suite for elemental rules.
##
## The owner can call `ElementalReactionScenarios.run_all()` from a Godot 4.7 test
## harness. An empty result means all scenarios passed; this repository has no GdUnit setup.
extends RefCounted
class_name ElementalReactionScenarios


## Runs threshold, resistance, immunity, reaction, environment and safety scenarios.
static func run_all() -> Array[String]:
	var failures: Array[String] = []
	var catalog := PrototypeElementalCatalog.create()
	_check_catalog(catalog, failures)
	_check_threshold_and_opposition(catalog, failures)
	_check_damage_multiplier(catalog, failures)
	_check_resistance_stacking(catalog, failures)
	_check_damage_immunity_does_not_block_status(catalog, failures)
	_check_status_immunity_does_not_block_damage(catalog, failures)
	_check_affinity_healing(catalog, failures)
	_check_environment_reactions(catalog, failures)
	_check_world_action_definitions(catalog, failures)
	_check_reaction_budget(catalog, failures)
	_check_duration_and_decay(catalog, failures)
	return failures


## Requires the prototype catalog to resolve every mandatory cross-reference.
static func _check_catalog(catalog: ElementalCatalog, failures: Array[String]) -> void:
	_expect(catalog.get_validation_errors().is_empty(), "catalog has validation errors", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_FIRE, ElementalIds.STATUS_BURNING), 1.2), "FIRE+BURNING multiplier must be 1.2", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_FIRE, ElementalIds.STATUS_WET), 0.8), "FIRE+WET multiplier must be 0.8", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_FIRE, ElementalIds.STATUS_COLD), 0.65), "FIRE+COLD multiplier must be 0.65", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_FIRE, ElementalIds.STATUS_FROZEN), 0.4), "FIRE+FROZEN multiplier must be 0.4", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_ICE, ElementalIds.STATUS_WET), 1.2), "ICE+WET multiplier must be 1.2", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_ICE, ElementalIds.STATUS_FROZEN), 1.25), "ICE+FROZEN multiplier must be 1.25", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_ICE, ElementalIds.STATUS_COLD), 1.5), "ICE+COLD multiplier must be 1.5", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_PHYSICAL, ElementalIds.STATUS_FROZEN), 2.5), "PHYSICAL+FROZEN multiplier must be 2.5", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_ELECTRIC, ElementalIds.STATUS_WET), 1.5), "ELECTRIC+WET multiplier must be 1.5", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_ELECTRIC, ElementalIds.STATUS_ELECTRIFIED), 1.2), "ELECTRIC+ELECTRIFIED multiplier must be 1.2", failures)
	_expect(is_equal_approx(catalog.get_damage_multiplier(ElementalIds.DAMAGE_ACID, ElementalIds.STATUS_WET), 1.0), "unspecified multiplier must default to 1.0", failures)
	_expect(is_equal_approx(catalog.get_resistance_multiplier(-1), 2.0), "resistance -1 multiplier must be 2.0", failures)
	_expect(is_equal_approx(catalog.get_resistance_multiplier(0), 1.0), "resistance 0 multiplier must be 1.0", failures)
	_expect(is_equal_approx(catalog.get_resistance_multiplier(1), 0.5), "resistance +1 multiplier must be 0.5", failures)
	_expect(is_equal_approx(catalog.get_resistance_multiplier(2), 0.0), "resistance +2 multiplier must be 0.0", failures)
	_expect(is_equal_approx(catalog.get_resistance_multiplier(3), -0.5), "resistance +3 multiplier must be -0.5", failures)
	_expect(is_equal_approx(catalog.get_resistance_multiplier(4), -1.0), "resistance +4 multiplier must be -1.0", failures)


## Verifies activation thresholds and proportional opposition instead of boolean cancellation.
static func _check_threshold_and_opposition(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var target := _subject(ElementalIds.TARGET_LIVING)
	var state := target.get_component(C_ElementalState) as C_ElementalState
	state.apply_status(catalog.get_status(ElementalIds.STATUS_BURNING), 100.0)
	var weak_cold := ElementalResolver.apply_status(
		target,
		ElementalStatusRequest.new(null, null, ElementalIds.STATUS_COLD, 1.0),
		catalog,
	)
	_expect(not weak_cold.transition.activated, "1 COLD buildup must remain below threshold", failures)
	_expect(is_equal_approx(state.get_status(ElementalIds.STATUS_BURNING).buildup, 100.0), "weak COLD must not remove strong BURNING", failures)
	ElementalResolver.apply_status(
		target,
		ElementalStatusRequest.new(null, null, ElementalIds.STATUS_COLD, 24.0),
		catalog,
	)
	_expect(is_equal_approx(state.get_status(ElementalIds.STATUS_BURNING).buildup, 50.0), "bounded chain must leave residual strong BURNING instead of clearing it", failures)
	_expect(not state.get_status(ElementalIds.STATUS_WET).active, "residual BURNING must consume generated WET through the next rule", failures)


## Verifies prototype sparse multipliers are applied before armor.
static func _check_damage_multiplier(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var target := _subject(ElementalIds.TARGET_LIVING)
	var state := target.get_component(C_ElementalState) as C_ElementalState
	state.apply_status(catalog.get_status(ElementalIds.STATUS_FROZEN), 60.0)
	var resolution := ElementalResolver.resolve_damage(
		target,
		DamageRequest.new(null, null, 10.0, Vector3.ZERO, Vector3.ZERO, DamageRequest.Kind.DIRECT, ElementalIds.DAMAGE_PHYSICAL),
		catalog,
	)
	_expect(is_equal_approx(resolution.status_multiplier, 2.5), "PHYSICAL+FROZEN multiplier must be 2.5", failures)
	_expect(is_equal_approx(resolution.health_amount_before_armor, 25.0), "10 physical against FROZEN must produce 25 pre-armor damage", failures)


## Verifies strongest-per-sign modifier stacking and final range clamp.
static func _check_resistance_stacking(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var profile := C_DamageResistances.new(ElementalIds.TARGET_LIVING)
	_expect(catalog.get_base_resistance(ElementalIds.TARGET_LIVING, ElementalIds.DAMAGE_NEGATIVE) == -1, "living NEGATIVE base must be -1", failures)
	_expect(catalog.get_base_resistance(ElementalIds.TARGET_LIVING, ElementalIds.DAMAGE_POSITIVE) == 4, "living POSITIVE base must be +4", failures)
	_expect(catalog.get_base_resistance(ElementalIds.TARGET_CONSTRUCT, ElementalIds.DAMAGE_NEGATIVE) == 2, "construct NEGATIVE base must be +2", failures)
	_expect(catalog.get_base_resistance(ElementalIds.TARGET_CONSTRUCT, ElementalIds.DAMAGE_POSITIVE) == 2, "construct POSITIVE base must be +2", failures)
	_expect(catalog.get_base_resistance(ElementalIds.TARGET_UNDEAD, ElementalIds.DAMAGE_POSITIVE) == -1, "undead POSITIVE base must be -1", failures)
	_expect(catalog.get_base_resistance(ElementalIds.TARGET_UNDEAD, ElementalIds.DAMAGE_NEGATIVE) == 4, "undead NEGATIVE base must be +4", failures)
	profile.set_modifier(ElementalIds.DAMAGE_NEGATIVE, &"blessing_a", 1)
	profile.set_modifier(ElementalIds.DAMAGE_NEGATIVE, &"blessing_b", 2)
	var level := ElementalResistanceResolver.get_final_resistance(profile, null, catalog, ElementalIds.DAMAGE_NEGATIVE)
	_expect(level == 1, "base -1 plus strongest positive +2 must equal +1", failures)
	profile.set_modifier(ElementalIds.DAMAGE_NEGATIVE, &"curse_a", -1)
	profile.set_modifier(ElementalIds.DAMAGE_NEGATIVE, &"curse_b", -3)
	level = ElementalResistanceResolver.get_final_resistance(profile, null, catalog, ElementalIds.DAMAGE_NEGATIVE)
	_expect(level == -1, "base -1 + strongest -3 + strongest +2 must clamp to -1", failures)


## Verifies damage immunity is independent from linked status buildup.
static func _check_damage_immunity_does_not_block_status(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var target := _subject(ElementalIds.TARGET_LIVING)
	var profile := target.get_component(C_DamageResistances) as C_DamageResistances
	profile.set_base_override(ElementalIds.DAMAGE_FIRE, 2)
	var resolution := ElementalResolver.resolve_damage(
		target,
		DamageRequest.new(null, null, 40.0, Vector3.ZERO, Vector3.ZERO, DamageRequest.Kind.DIRECT, ElementalIds.DAMAGE_FIRE),
		catalog,
	)
	var state := target.get_component(C_ElementalState) as C_ElementalState
	_expect(is_zero_approx(resolution.health_amount_before_armor), "FIRE resistance +2 must prevent health damage", failures)
	_expect(state.get_status(ElementalIds.STATUS_BURNING).active, "damage immunity must not imply BURNING immunity", failures)


## Verifies status immunity blocks buildup without changing health damage resistance.
static func _check_status_immunity_does_not_block_damage(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var target := _subject(ElementalIds.TARGET_LIVING)
	var immunities := target.get_component(C_StatusImmunities) as C_StatusImmunities
	immunities.add_immunity(ElementalIds.STATUS_BURNING)
	var resolution := ElementalResolver.resolve_damage(
		target,
		DamageRequest.new(null, null, 40.0, Vector3.ZERO, Vector3.ZERO, DamageRequest.Kind.DIRECT, ElementalIds.DAMAGE_FIRE),
		catalog,
	)
	var state := target.get_component(C_ElementalState) as C_ElementalState
	_expect(is_equal_approx(resolution.health_amount_before_armor, 40.0), "BURNING immunity must not change FIRE damage", failures)
	_expect(state.get_status(ElementalIds.STATUS_BURNING) == null, "BURNING immunity must block buildup", failures)


## Verifies negative resistance multipliers are represented as healing amounts.
static func _check_affinity_healing(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var target := _subject(ElementalIds.TARGET_LIVING)
	var resolution := ElementalResolver.resolve_damage(
		target,
		DamageRequest.new(null, null, 10.0, Vector3.ZERO, Vector3.ZERO, DamageRequest.Kind.DIRECT, ElementalIds.DAMAGE_POSITIVE),
		catalog,
	)
	_expect(resolution.resistance_level == 4, "living POSITIVE base resistance must be +4", failures)
	_expect(is_equal_approx(resolution.health_amount_before_armor, -10.0), "affinity +4 must convert 10 damage into 10 healing", failures)


## Verifies material tags transform water and earth through the shared subject model.
static func _check_environment_reactions(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var water := _subject(ElementalIds.TARGET_CONSTRUCT)
	var materials := water.get_component(C_ReactiveMaterials) as C_ReactiveMaterials
	materials.add_material(ElementalIds.MATERIAL_WATER)
	var electric := DamageRequest.new(null, null, 10.0, Vector3.ZERO, Vector3.ZERO, DamageRequest.Kind.DIRECT, ElementalIds.DAMAGE_ELECTRIC)
	var water_result := ElementalResolver.resolve_damage(water, electric, catalog)
	_expect(materials.has_material(ElementalIds.SURFACE_ELECTRIFIED_WATER), "ELECTRIC+WATER must transform the surface", failures)
	_expect(&"electric_charges_water" in water_result.triggered_reactions, "electric water reaction must be traced", failures)
	var earth := _subject(ElementalIds.TARGET_CONSTRUCT)
	var earth_materials := earth.get_component(C_ReactiveMaterials) as C_ReactiveMaterials
	earth_materials.add_material(ElementalIds.MATERIAL_EARTH)
	var fire := DamageRequest.new(null, null, 10.0, Vector3.ZERO, Vector3.ZERO, DamageRequest.Kind.DIRECT, ElementalIds.DAMAGE_FIRE)
	ElementalResolver.resolve_damage(earth, fire, catalog)
	_expect(earth_materials.has_material(ElementalIds.SURFACE_LAVA), "FIRE+EARTH must transform the surface to LAVA", failures)


## Verifies prototype reactions expose spawn, transform and nested damage action variants.
static func _check_world_action_definitions(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var fire_wet := catalog.get_reactions(
		ElementalReactionDefinition.TriggerKind.DAMAGE_STATUS,
		ElementalIds.DAMAGE_FIRE,
		ElementalIds.STATUS_WET,
	)
	var poison_material := catalog.get_reactions(
		ElementalReactionDefinition.TriggerKind.DAMAGE_MATERIAL,
		ElementalIds.DAMAGE_POISON,
		ElementalIds.MATERIAL_POISON,
	)
	var overload := catalog.get_reactions(
		ElementalReactionDefinition.TriggerKind.DAMAGE_STATUS,
		ElementalIds.DAMAGE_ELECTRIC,
		ElementalIds.STATUS_ELECTRIFIED,
	)
	_expect(_has_action(fire_wet, ElementalReactionActionDefinition.Kind.SPAWN_ENTITY, ElementalIds.ENTITY_WET_MIST), "FIRE+WET must request wet mist spawn", failures)
	_expect(_has_action(poison_material, ElementalReactionActionDefinition.Kind.SPAWN_ENTITY, ElementalIds.ENTITY_POISON_CLOUD), "POISON material reaction must request poison cloud spawn", failures)
	_expect(_has_action(overload, ElementalReactionActionDefinition.Kind.DEAL_DAMAGE), "ELECTRIC overload must demonstrate nested damage", failures)


## Verifies a deliberately tiny queue budget terminates a multi-action reaction.
static func _check_reaction_budget(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var target := _subject(ElementalIds.TARGET_LIVING)
	var state := target.get_component(C_ElementalState) as C_ElementalState
	state.apply_status(catalog.get_status(ElementalIds.STATUS_BURNING), 100.0)
	var context := ElementalResolutionContext.new(1, 2)
	ElementalResolver.apply_status(
		target,
		ElementalStatusRequest.new(null, null, ElementalIds.STATUS_COLD, 30.0, context),
		catalog,
	)
	_expect(context.remaining_actions == 0, "reaction queue must stop at configured action budget", failures)
	_expect(context.triggered_reaction_ids.size() == 1, "reaction fingerprint must prevent duplicate rule entry", failures)


## Verifies active duration expiry clears state and inactive buildup decays predictably.
static func _check_duration_and_decay(catalog: ElementalCatalog, failures: Array[String]) -> void:
	var state := C_ElementalState.new()
	var burning := catalog.get_status(ElementalIds.STATUS_BURNING)
	state.apply_status(burning, 30.0)
	state.advance(1.0)
	_expect(is_equal_approx(state.get_status(ElementalIds.STATUS_BURNING).buildup, 25.0), "BURNING must decay by 5 buildup per second", failures)
	state.advance(7.0)
	_expect(state.get_status(ElementalIds.STATUS_BURNING) == null, "duration expiry must clear BURNING runtime state", failures)


## Creates a minimal non-spatial elemental subject for pure resolver scenarios.
static func _subject(target_type: StringName) -> Entity:
	var subject := Entity.new()
	subject.add_component(C_ElementalState.new())
	subject.add_component(C_DamageResistances.new(target_type))
	subject.add_component(C_StatusImmunities.new())
	subject.add_component(C_ReactiveMaterials.new())
	return subject


## Finds an action kind and optional semantic ID in typed reaction definitions.
static func _has_action(
	reactions: Array[ElementalReactionDefinition],
	kind: ElementalReactionActionDefinition.Kind,
	semantic_id: StringName = &"",
) -> bool:
	for reaction in reactions:
		for action in reaction.actions:
			if action.kind == kind and (semantic_id == &"" or action.semantic_id == semantic_id):
				return true
	return false


## Appends a readable failure without aborting later scenarios.
static func _expect(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
