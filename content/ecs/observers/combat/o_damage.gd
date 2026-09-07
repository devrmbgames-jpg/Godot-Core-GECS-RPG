## Применяет targeted DamageRequest к C_Health и выставляет C_Dead.
extends Observer
class_name O_Damage

var _elemental_catalog: ElementalCatalog = PrototypeElementalCatalog.create()


## Слушает damage requests на actors и без-health environment subjects.
func query() -> QueryBuilder:
	return q.on_event(DamageService.EVENT_DAMAGE_REQUESTED)


## Валидирует CombatRules, разрешает elemental rules, затем применяет Armor только к положительному damage.
## Отрицательный resistance multiplier отправляет величину в typed HealService pipeline.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var damage := payload as DamageRequest
	if target == null or damage == null or not CombatRules.can_damage(damage.source, target):
		return
	var health := target.get_component(C_Health) as C_Health
	var has_elemental_subject := (
		target.has_component(C_ElementalState)
		or target.has_component(C_DamageResistances)
		or target.has_component(C_ReactiveMaterials)
	)
	if health == null and not has_elemental_subject:
		return
	var armor := target.get_component(C_Armor) as C_Armor
	var armor_value := armor.value if armor != null else 0.0
	var resolution := ElementalResolver.resolve_damage(target, damage, _elemental_catalog)
	var applied := 0.0
	if health != null and resolution.health_amount_before_armor > 0.0:
		applied = _mitigate(resolution.health_amount_before_armor, armor_value)
		health.current = maxf(0.0, health.current - applied)
		resolution.health_damage_after_armor = applied
		if applied > 0.0:
			ECS.world.emit_event(
				DamageService.EVENT_DAMAGE_APPLIED,
				target,
				DamageAppliedEvent.new(damage, applied, health.current, resolution),
			)
	elif health != null and resolution.health_amount_before_armor < 0.0:
		resolution.healing_requested = -resolution.health_amount_before_armor
		HealService.request(target, HealRequest.new(damage.source, damage.ability, resolution.healing_requested))
	ECS.world.emit_event(ElementalService.EVENT_DAMAGE_RESOLVED, target, resolution)
	if health != null and health.current <= 0.0 and not target.has_component(C_Dead):
		cmd.add_component(target, C_Dead.new())


## Применяет hyperbolic armor formula; отрицательная Armor увеличивает входящий damage.
func _mitigate(raw_damage: float, armor: float) -> float:
	if armor >= 0.0:
		return raw_damage * (100.0 / (100.0 + armor))
	return raw_damage * (2.0 - 100.0 / (100.0 - armor))
