## Applies typed damage requests, including elemental resistance, buildup and affinity healing.
## C_Health/C_Dead remain authoritative; healing is delegated to the existing HealService.
extends Observer
class_name O_Damage


## Listens to damage requests on health-bearing targets; environmental targets use a separate observer.
func query() -> QueryBuilder:
	return q.with_all([C_Health]).on_event(DamageService.EVENT_DAMAGE_REQUESTED)


## Validates team policy before any mutation, resolves elements, then applies armor and health changes.
## An affinity heal emits HealService's normal event, not a misleading positive DamageAppliedEvent.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var damage := payload as DamageRequest
	if target == null or damage == null or not is_instance_valid(target):
		return
	var health := target.get_component(C_Health) as C_Health
	if health.current <= 0.0 or target.has_component(C_Dead):
		if health.current <= 0.0 and not target.has_component(C_Dead):
			cmd.add_component(target, C_Dead.new())
		return
	var definitions := ElementalService.catalog()
	if not definitions.has_damage_type(damage.damage_type) or damage.reaction_depth > ElementalChain.MAX_DEPTH:
		return
	var state := target.get_component(C_ElementalState) as C_ElementalState
	if state == null:
		state = C_ElementalState.new()
	var preview := ElementalResolver.preview_damage(state, definitions, damage.damage_type, damage.amount)
	if preview < 0.0:
		if not CombatRules.can_damage(damage.source, target) and not CombatRules.can_heal(damage.source, target):
			return
	elif not CombatRules.can_damage(damage.source, target):
		return
	var result := ElementalResolver.resolve_damage(state, definitions, damage)
	if result.signed_damage < 0.0:
		HealService.request(target, HealRequest.new(damage.source, damage.ability, -result.signed_damage))
		ElementalService.dispatch(target, result)
		return
	var armor := target.get_component(C_Armor) as C_Armor
	var armor_value := armor.value if armor != null else 0.0
	var applied := _mitigate(result.signed_damage, armor_value)
	health.current = maxf(0.0, health.current - applied)
	ECS.world.emit_event(
		DamageService.EVENT_DAMAGE_APPLIED,
		target,
		DamageAppliedEvent.new(damage, applied, health.current),
	)
	if health.current <= 0.0 and not target.has_component(C_Dead):
		cmd.add_component(target, C_Dead.new())
	ElementalService.dispatch(target, result)


## Applies the existing hyperbolic armor formula only to nonnegative damage.
## Negative armor amplifies damage; signed affinity healing bypasses armor entirely.
func _mitigate(raw_damage: float, armor: float) -> float:
	if armor >= 0.0:
		return raw_damage * (100.0 / (100.0 + armor))
	return raw_damage * (2.0 - 100.0 / (100.0 - armor))
