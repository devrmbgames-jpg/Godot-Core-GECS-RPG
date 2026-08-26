## Demo consumer: interaction с EffectStation применяет выбранный стандартный effect к actor.
extends Observer
class_name O_DemoEffectStation


## Слушает activated interaction events только на demo effect stations.
func query() -> QueryBuilder:
	return q.with_all([C_DemoEffectStation, C_Interactable]).on_event(InteractionService.EVENT_ACTIVATED)


## Разрешает marker id в demo definition и вызывает production EffectService на interacting actor.
func each(_event: Variant, station: Entity, payload: Variant = null) -> void:
	var request := payload as InteractionRequest
	var marker := station.get_component(C_DemoEffectStation) as C_DemoEffectStation
	if request == null or request.actor == null or marker == null:
		return
	var definition := _definition(marker.effect_id)
	if definition != null:
		EffectService.request(request.actor, definition, station)


## Возвращает новую demo EffectDefinition для stable catalog id либо null для unknown id.
func _definition(effect_id: StringName) -> EffectDefinition:
	match effect_id:
		&"poison": return DemoEffectCatalog.poison()
		&"burning": return DemoEffectCatalog.burning()
		&"heal": return DemoEffectCatalog.heal()
		&"regeneration": return DemoEffectCatalog.regeneration()
		&"haste": return DemoEffectCatalog.haste()
		&"slow": return DemoEffectCatalog.slow()
	return null
