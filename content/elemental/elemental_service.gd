## Stateless ECS event boundary for direct statuses and reaction/world notifications.
extends RefCounted
class_name ElementalService

const EVENT_STATUS_REQUESTED: StringName = &"elemental_status_requested"
const EVENT_STATUS_RESOLVED: StringName = &"elemental_status_resolved"
const EVENT_DAMAGE_RESOLVED: StringName = &"elemental_damage_resolved"
const EVENT_REACTION_TRIGGERED: StringName = &"elemental_reaction_triggered"
const EVENT_WORLD_ACTION_REQUESTED: StringName = &"elemental_world_action_requested"


## Publishes a targeted direct status request; damage is not required.
static func request_status(target: Entity, request: ElementalStatusRequest) -> void:
	if ECS.world == null or target == null or request == null:
		return
	ECS.world.emit_event(EVENT_STATUS_REQUESTED, target, request)


## Publishes all direct status entries from an ability without requiring damage.
static func request_statuses(
	target: Entity,
	applications: Array[ElementalStatusApplicationDefinition],
	source: Entity = null,
	ability: Entity = null,
	hit_position: Vector3 = Vector3.ZERO,
	direction: Vector3 = Vector3.ZERO,
) -> void:
	var context := ElementalResolutionContext.new()
	for application in applications:
		if application != null and application.status_id != &"" and application.buildup_amount > 0.0:
			request_status(target, ElementalStatusRequest.new(
				source, ability, application.status_id, application.buildup_amount,
				context, hit_position, direction,
			))


## Publishes a semantic action for environment/presentation adapters.
static func publish_world_action(target: Entity, event: ElementalWorldActionEvent) -> void:
	if ECS.world == null or target == null or event == null:
		return
	ECS.world.emit_event(EVENT_WORLD_ACTION_REQUESTED, target, event)
