## Превращает targeted EffectApplyRequest в effect lifecycle operation.
extends Observer
class_name O_EffectApply


func query() -> QueryBuilder:
	return q.on_event(EffectService.EVENT_APPLY)


func each(_event: Variant, target: Entity, payload: Variant) -> void:
	var request := payload as EffectApplyRequest
	if target == null or request == null or target.has_component(C_Dead):
		return
	cmd.add_custom(func(): EffectRuntime.apply(target, request))
