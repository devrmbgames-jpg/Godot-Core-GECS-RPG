## Stateless targeted healing boundary.
extends RefCounted
class_name HealService

const EVENT_HEAL_REQUESTED: StringName = &"heal_requested"
const EVENT_HEAL_APPLIED: StringName = &"heal_applied"


## Публикует targeted HealRequest; фактический clamp к MaxHealth выполняется O_Heal.
static func request(target: Entity, request: HealRequest) -> void:
	if ECS.world == null or target == null or request == null:
		return
	ECS.world.emit_event(EVENT_HEAL_REQUESTED, target, request)
