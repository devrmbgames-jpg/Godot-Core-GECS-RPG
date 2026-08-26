## Direct damage поддерживает combat state у получателя и источника.
extends Observer
class_name O_CombatDamage


func query() -> QueryBuilder:
	return q.on_event(DamageService.EVENT_DAMAGE_APPLIED)


func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var applied: DamageAppliedEvent = payload as DamageAppliedEvent
	if applied == null or applied.request == null:
		return
	if applied.request.kind != DamageRequest.Kind.DIRECT:
		return
	CombatStateService.refresh(target)
	if applied.request.source != null:
		CombatStateService.refresh(applied.request.source)
