## Stateless boundary for typed damage requests, preserving the existing HP damage event contract.
extends RefCounted
class_name DamageService

const EVENT_DAMAGE_REQUESTED: StringName = &"damage_requested"
const EVENT_DAMAGE_APPLIED: StringName = &"damage_applied"


## Publishes a targeted DamageRequest. Healthless elemental entities use the environmental observer.
## Health-bearing targets retain O_Damage as their only HP/death authority.
static func request(target: Entity, damage: DamageRequest) -> void:
	if ECS.world == null or target == null or damage == null or not is_instance_valid(target):
		return
	if not target.has_component(C_Health) and target.has_component(C_ElementalState):
		ECS.world.emit_event(ElementalService.EVENT_ENVIRONMENT_IMPACT, target, damage)
	else:
		ECS.world.emit_event(EVENT_DAMAGE_REQUESTED, target, damage)
