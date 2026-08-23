## Применяет HealRequest с учётом resolved MaxHealth.
extends Observer
class_name O_Heal


func query() -> QueryBuilder:
	return q.with_all([C_Health, C_MaxHealth]).on_event(HealService.EVENT_HEAL_REQUESTED)


func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var request := payload as HealRequest
	if target == null or request == null or target.has_component(C_Dead):
		return
	var health := target.get_component(C_Health) as C_Health
	var maximum := target.get_component(C_MaxHealth) as C_MaxHealth
	var before := health.current
	health.current = minf(maximum.value, health.current + maxf(request.amount, 0.0))
	var applied := health.current - before
	ECS.world.emit_event(
		HealService.EVENT_HEAL_APPLIED,
		target,
		HealAppliedEvent.new(request, applied, health.current),
	)
