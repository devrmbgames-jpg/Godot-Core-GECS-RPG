## Demo consumer: interaction с размещённым Item Entity добавляет его в inventory и экипирует.
extends Observer
class_name O_DemoItemStation


func query() -> QueryBuilder:
	return q.with_all([C_Item, C_Interactable]).on_event(InteractionService.EVENT_ACTIVATED)


func each(_event: Variant, item: Entity, payload: Variant) -> void:
	var request := payload as InteractionRequest
	if request == null or request.actor == null:
		return
	var inventory := request.actor.get_component(C_Inventory) as C_Inventory
	if inventory != null:
		inventory.add(item)
	EquipmentService.equip(request.actor, item)
