## Активирует уже выбранную Area3D interaction target без raycast.
extends System
class_name S_InteractionIntent


## Выбирает живых actors, у которых controller intent может активировать selected interaction target.
func query() -> QueryBuilder:
	return q.with_all([C_ControllerIntent, C_InteractionSensor]).with_none([C_Dead]).iterate([C_ControllerIntent, C_InteractionSensor])


## На interact one-shot повторно валидирует selected target в overlap set и публикует InteractionService request.
func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var intents: Array = components[0]
	var sensors: Array = components[1]
	for index in entities.size():
		var intent: C_ControllerIntent = intents[index] as C_ControllerIntent
		if not intent.interact_pressed:
			continue
		var actor: Entity = entities[index]
		var sensor: C_InteractionSensor = sensors[index] as C_InteractionSensor
		var target: Entity = sensor.selected_target
		if target != null and InteractionTargeting.contains_valid(actor, sensor, target):
			InteractionService.request(actor, target)
