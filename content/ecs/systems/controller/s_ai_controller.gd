## Копирует output AI steering/behavior в общий Controller intent.
## Конкретное поведение AI не входит в эту систему.
extends System
class_name S_AIController


func query() -> QueryBuilder:
	return q.with_all([C_AIController, C_ControllerIntent]).with_none([C_Dead]).iterate([C_AIController, C_ControllerIntent])


func process(_entities: Array[Entity], components: Array, _delta: float) -> void:
	var controllers: Array = components[0]
	var intents: Array = components[1]
	for index in controllers.size():
		var controller: C_AIController = controllers[index] as C_AIController
		var intent: C_ControllerIntent = intents[index] as C_ControllerIntent
		if not controller.enabled:
			intent.move_direction = Vector3.ZERO
			intent.facing_direction = Vector3.ZERO
			intent.primary_pressed = false
			intent.secondary_pressed = false
			intent.skill_1_pressed = false
			intent.interact_pressed = false
			controller.wants_primary = false
			controller.wants_secondary = false
			controller.wants_skill_1 = false
			controller.wants_interact = false
			continue
		intent.move_direction = controller.desired_move_direction.limit_length(1.0)
		intent.facing_direction = controller.desired_facing_direction
		intent.aim_direction = controller.desired_facing_direction
		intent.primary_pressed = controller.wants_primary
		intent.secondary_pressed = controller.wants_secondary
		intent.skill_1_pressed = controller.wants_skill_1
		intent.interact_pressed = controller.wants_interact
		controller.wants_primary = false
		controller.wants_secondary = false
		controller.wants_skill_1 = false
		controller.wants_interact = false
