## Demo consumer: reusable equipment station создаёт Item Entity, кладёт в inventory и экипирует.
extends Observer
class_name O_DemoItemStation


func query() -> QueryBuilder:
	return q.with_all([C_DemoItemStation, C_Interactable]).on_event(InteractionService.EVENT_ACTIVATED)


func each(_event: Variant, station: Entity, payload: Variant) -> void:
	var request := payload as InteractionRequest
	var marker := station.get_component(C_DemoItemStation) as C_DemoItemStation
	if request == null or request.actor == null or marker == null:
		return
	var definition := _definition(marker.item_id)
	if definition == null:
		return
	var item := ItemFactory.give(request.actor, definition)
	if item != null:
		EquipmentService.equip(request.actor, item)


func _definition(item_id: StringName) -> ItemDefinition:
	match item_id:
		&"sword": return DemoItemCatalog.sword()
		&"bow": return DemoItemCatalog.bow()
		&"staff": return DemoItemCatalog.staff()
	return null
