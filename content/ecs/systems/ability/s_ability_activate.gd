## Валидирует и запускает один queued ability request на actor за frame.
##
## C_Casting — постоянный runtime-state: frequent attacks не делают archetype churn.
extends System
class_name S_AbilityActivate


## Выбирает actors с ability queue, persistent casting state и mana-cost runtime stats.
func query() -> QueryBuilder:
	return q.with_all([C_AbilityQueue, C_Casting, C_Mana, C_ManaCostMultiplier])


## Consumes один slot, проверяет death/cast/cooldown/mana, списывает cost и запускает instant/cast delivery.
## Player target_position берётся из cursor aim; AI target — из C_CombatTarget.
func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
	for actor in entities:
		var queue := actor.get_component(C_AbilityQueue) as C_AbilityQueue
		if queue == null or queue.slots.is_empty():
			continue
		var slot := queue.pop()
		var casting := actor.get_component(C_Casting) as C_Casting
		if actor.has_component(C_Dead) or casting == null or casting.active:
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
		var definition: AbilityDefinition = ability_component.definition
		var mana := actor.get_component(C_Mana) as C_Mana
		var mana_multiplier := actor.get_component(C_ManaCostMultiplier) as C_ManaCostMultiplier
		var cost := maxf(0.0, definition.base_mana_cost * mana_multiplier.value)
		if mana.current < cost:
			continue
		mana.current -= cost
		cooldown.remaining = maxf(0.0, definition.base_cooldown)
		var target: Entity
		var target_position: Vector3 = Vector3.ZERO
		if actor.has_component(C_PlayerController):
			var intent: C_ControllerIntent = actor.get_component(C_ControllerIntent) as C_ControllerIntent
			if intent != null:
				target_position = intent.aim_world_position
		else:
			var target_component := actor.get_component(C_CombatTarget) as C_CombatTarget
			target = target_component.target if target_component != null else null
		if definition.is_offensive:
			CombatStateService.refresh(actor)
		PresentationService.publish(
			actor,
			PresentationActionEvent.for_ability(definition.presentation_action, &"start", ability),
		)
		if definition.base_cast_work <= 0.0 or definition.timing == AbilityDefinition.Timing.INSTANT:
			AbilityResolver.resolve(actor, ability, target, target_position, cmd)
		else:
			casting.start(ability, target, target_position, definition.base_cast_work, definition.timing)
