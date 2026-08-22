## Demo definitions стандартных Action RPG effects.
extends RefCounted
class_name DemoEffectCatalog


static func poison() -> EffectDefinition:
	var effect := EffectDefinition.new()
	effect.id = &"poison"
	effect.display_name = "Poison"
	effect.duration = 6.0
	effect.tick_interval = 1.0
	effect.damage_per_tick = 4.0
	effect.stack_policy = EffectDefinition.StackPolicy.STACK
	effect.max_stacks = 5
	effect.presentation_action = &"poison"
	return effect


static func burning() -> EffectDefinition:
	var effect := EffectDefinition.new()
	effect.id = &"burning"
	effect.display_name = "Burning"
	effect.duration = 4.0
	effect.tick_interval = 0.5
	effect.damage_per_tick = 3.0
	effect.stack_policy = EffectDefinition.StackPolicy.REFRESH
	effect.presentation_action = &"burning"
	return effect


static func heal(amount: float = 30.0) -> EffectDefinition:
	var effect := EffectDefinition.new()
	effect.id = &"heal"
	effect.display_name = "Heal"
	effect.instant_heal = amount
	effect.presentation_action = &"heal"
	return effect


static func regeneration() -> EffectDefinition:
	var effect := EffectDefinition.new()
	effect.id = &"regeneration"
	effect.display_name = "Regeneration"
	effect.duration = 8.0
	effect.tick_interval = 1.0
	effect.heal_per_tick = 5.0
	effect.stack_policy = EffectDefinition.StackPolicy.REFRESH
	effect.presentation_action = &"regeneration"
	return effect


static func haste() -> EffectDefinition:
	var effect := EffectDefinition.new()
	effect.id = &"haste"
	effect.display_name = "Haste"
	effect.duration = 6.0
	effect.stack_policy = EffectDefinition.StackPolicy.REFRESH
	effect.stat_modifiers = [
		EffectStatModifier.new(C_AttackSpeed, R_ModifiesStat.Operation.INCREASED, 0.25),
		EffectStatModifier.new(C_CastSpeed, R_ModifiesStat.Operation.INCREASED, 0.25),
		EffectStatModifier.new(C_CooldownRecovery, R_ModifiesStat.Operation.INCREASED, 0.25),
	]
	effect.presentation_action = &"haste"
	return effect


static func slow() -> EffectDefinition:
	var effect := EffectDefinition.new()
	effect.id = &"slow"
	effect.display_name = "Slow"
	effect.duration = 4.0
	effect.stack_policy = EffectDefinition.StackPolicy.REFRESH
	effect.stat_modifiers = [
		EffectStatModifier.new(C_MoveSpeed, R_ModifiesStat.Operation.MORE, 0.60),
	]
	effect.presentation_action = &"slow"
	return effect
