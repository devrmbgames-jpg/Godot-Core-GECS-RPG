## Валидирует и запускает один queued ability request на actor за frame.
##
## Mana/cooldown относятся к runtime state; immutable AbilityDefinition не мутируется.
extends System
class_name S_AbilityActivate


func query() -> QueryBuilder:
	return q.with_all([C_AbilityQueue, C_Mana, C_ManaCostMultiplier])


func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
	for actor in entities:
		var queue := actor.get_component(C_AbilityQueue) as C_AbilityQueue
		if queue == null or queue.slots.is_empty():
			continue
		var slot := queue.pop()
		if actor.has_component(C_Dead) or actor.has_component(C_Casting):
			continue
		var ability := AbilityFactory.find_ability(actor, slot)
		if ability == null:
			continue
		var ability_component := ability.get_component(C_Ability) as C_Ability
		var cooldown := ability.get_component(C_Cooldown) as C_Cooldown
		if ability_component == null or ability_component.definition == null or cooldown == null:
			continue
		if cooldown.remaining > 0.0:
			continue
		var definition := ability_component.definition
		var mana := actor.get_component(C_Mana) as C_Mana
		var mana_multiplier := actor.get_component(C_ManaCostMultiplier) as C_ManaCostMultiplier
		var cost := maxf(0.0, definition.base_mana_cost * mana_multiplier.value)
		if mana.current < cost:
			continue
		mana.current -= cost
		cooldown.remaining = maxf(0.0, definition.base_cooldown)
		var target_component := actor.get_component(C_CombatTarget) as C_CombatTarget
		var target := target_component.target if target_component != null else null
		ECS.world.emit_event(
			&"presentation_action",
			actor,
			{"action": definition.presentation_action, "phase": &"start", "ability": ability},
		)
		if definition.base_cast_work <= 0.0 or definition.timing == AbilityDefinition.Timing.INSTANT:
			AbilityResolver.resolve(actor, ability, target, Vector3.ZERO, cmd)
		else:
			cmd.add_component(
				actor,
				C_Casting.new(ability, target, Vector3.ZERO, definition.base_cast_work, definition.timing),
			)
