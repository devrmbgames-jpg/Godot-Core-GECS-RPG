## Переводит typed semantic presentation events в CharacterRig operations.
extends Observer
class_name O_RigPresentation


func query() -> QueryBuilder:
	return q.on_event(PresentationService.EVENT_ACTION)


func each(_event: Variant, actor: Entity, payload: Variant = null) -> void:
	var presentation := payload as PresentationActionEvent
	if actor == null or presentation == null:
		return
	var rig := RigLocator.find(actor)
	if rig == null:
		return
	if presentation.action == &"equip_item":
		if presentation.item_definition != null:
			rig.attach_equipment(
				presentation.item_definition.rig_socket,
				presentation.item_definition.visual_scene,
			)
		return
	if presentation.action == &"unequip_item":
		if presentation.item_definition != null:
			rig.detach_equipment(presentation.item_definition.rig_socket)
		return
	rig.play_action(presentation.action, presentation.phase)
