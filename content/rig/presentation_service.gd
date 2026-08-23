## Stateless typed boundary между gameplay и presentation/rig layer.
extends RefCounted
class_name PresentationService

const EVENT_ACTION: StringName = &"presentation_action"


## Публикует только PresentationActionEvent; Dictionary payload здесь запрещён контрактом API.
static func publish(actor: Entity, event: PresentationActionEvent) -> void:
	if ECS.world == null or actor == null or event == null:
		return
	ECS.world.emit_event(EVENT_ACTION, actor, event)
