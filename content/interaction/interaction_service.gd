## Stateless boundary для interaction requests/activation events.
extends RefCounted
class_name InteractionService

const EVENT_REQUESTED: StringName = &"interaction_requested"
const EVENT_ACTIVATED: StringName = &"interaction_activated"
const EVENT_STATE_CHANGED: StringName = &"activation_changed"


## Публикует targeted interaction request на target; validation выполняет O_Interaction.
static func request(actor: Entity, target: Entity) -> void:
	if ECS.world != null and actor != null and target != null:
		ECS.world.emit_event(EVENT_REQUESTED, target, InteractionRequest.new(actor))
