## Переводит semantic presentation_action events в CharacterRig operations.
extends Observer
class_name O_RigPresentation


func query() -> QueryBuilder:
	return q.on_event(&"presentation_action")


func each(_event: Variant, actor: Entity, payload: Variant = null) -> void:
	if actor == null or not (payload is Dictionary):
		return
	var rig := RigLocator.find(actor)
	if rig == null:
		return
	var action := StringName(payload.get("action", &""))
	var phase := StringName(payload.get("phase", &"start"))
	if action == &"equip_item":
		var definition := payload.get("definition") as ItemDefinition
		if definition != null:
			rig.attach_equipment(definition.rig_socket, definition.visual_scene)
		return
	if action == &"unequip_item":
		var definition := payload.get("definition") as ItemDefinition
		if definition != null:
			rig.detach_equipment(definition.rig_socket)
		return
	rig.play_action(action, phase)
