## Stateless boundary для мгновенных damage requests.
extends RefCounted
class_name DamageService

const EVENT_DAMAGE_REQUESTED: StringName = &"damage_requested"
const EVENT_DAMAGE_APPLIED: StringName = &"damage_applied"


static func request(target: Entity, damage: DamageRequest) -> void:
	if ECS.world == null or target == null or damage == null:
		return
	ECS.world.emit_event(EVENT_DAMAGE_REQUESTED, target, damage)
