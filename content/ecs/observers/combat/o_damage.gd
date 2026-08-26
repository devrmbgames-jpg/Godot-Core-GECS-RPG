## Применяет targeted DamageRequest к C_Health и выставляет C_Dead.
extends Observer
class_name O_Damage


## Слушает damage requests только на targets с C_Health.
func query() -> QueryBuilder:
	return q.with_all([C_Health]).on_event(DamageService.EVENT_DAMAGE_REQUESTED)


## Валидирует CombatRules, применяет Armor mitigation, мутирует Health, публикует result и deferred-add C_Dead.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var damage := payload as DamageRequest
	if target == null or damage == null or not CombatRules.can_damage(damage.source, target):
		return
	var health := target.get_component(C_Health) as C_Health
	var armor := target.get_component(C_Armor) as C_Armor
	var armor_value := armor.value if armor != null else 0.0
	var applied := _mitigate(maxf(damage.amount, 0.0), armor_value)
	health.current = maxf(0.0, health.current - applied)
	ECS.world.emit_event(
		DamageService.EVENT_DAMAGE_APPLIED,
		target,
		DamageAppliedEvent.new(damage, applied, health.current),
	)
	if health.current <= 0.0 and not target.has_component(C_Dead):
		cmd.add_component(target, C_Dead.new())


## Применяет hyperbolic armor formula; отрицательная Armor увеличивает входящий damage.
func _mitigate(raw_damage: float, armor: float) -> float:
	if armor >= 0.0:
		return raw_damage * (100.0 / (100.0 + armor))
	return raw_damage * (2.0 - 100.0 / (100.0 - armor))
