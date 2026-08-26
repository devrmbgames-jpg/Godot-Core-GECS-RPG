## AI interaction bridge: принимает только цель, выбранную AI decision layer.
##
## Сейчас это намеренная заглушка: будущий utility/behavior system записывает
## C_AIInteractionGoal.target и request_interaction. Здесь нет эвристики `nearest`.
extends System
class_name S_AIInteractionSelection


func query() -> QueryBuilder:
	return q.with_all([C_AIController, C_AIInteractionGoal, C_InteractionSensor]).with_none([C_Dead]).iterate([C_AIController, C_AIInteractionGoal, C_InteractionSensor])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var controllers: Array = components[0]
	var goals: Array = components[1]
	var sensors: Array = components[2]
	for index in entities.size():
		var actor: Entity = entities[index]
		var controller: C_AIController = controllers[index] as C_AIController
		var goal: C_AIInteractionGoal = goals[index] as C_AIInteractionGoal
		var sensor: C_InteractionSensor = sensors[index] as C_InteractionSensor
		var selected: Entity = goal.target if InteractionTargeting.contains_valid(actor, sensor, goal.target) else null
		InteractionSelectionService.set_target(actor, selected)
		if goal.request_interaction and selected != null:
			controller.wants_interact = true
		goal.request_interaction = false
