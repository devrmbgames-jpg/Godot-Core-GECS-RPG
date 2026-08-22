## Reactive boundary для equip/unequip requests.
extends Observer
class_name O_Equipment


func query() -> QueryBuilder:
	return q.on_event(EquipmentService.EVENT_EQUIP).on_event(EquipmentService.EVENT_UNEQUIP)


func each(event: Variant, actor: Entity, payload: Variant = null) -> void:
	var request := payload as EquipmentRequest
	if actor == null or request == null or request.item == null:
		return
	if event == EquipmentService.EVENT_EQUIP:
		cmd.add_custom(func(): EquipmentRuntime.equip(actor, request.item))
	elif event == EquipmentService.EVENT_UNEQUIP:
		cmd.add_custom(func(): EquipmentRuntime.unequip(actor, request.item))
