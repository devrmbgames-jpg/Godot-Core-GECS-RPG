## Копирует output AI steering/behavior в общий Controller intent.
##
## Конкретное поведение AI не входит в эту систему: оно только производит desired data.
extends System
class_name S_AIController


func query() -> QueryBuilder:
	return q.with_all([C_AIController, C_ControllerIntent]).iterate([C_AIController, C_ControllerIntent])


func process(_entities: Array[Entity], components: Array, _delta: float) -> void:
	var controllers: Array = components[0]
	var intents: Array = components[1]
	for index in controllers.size():
		var controller := controllers[index] as C_AIController
		var intent := intents[index] as C_ControllerIntent
		intent.move_direction = controller.desired_move_direction.limit_length(1.0)
		intent.facing_direction = controller.desired_facing_direction
		intent.primary_pressed = controller.wants_primary
		intent.secondary_pressed = controller.wants_secondary
		intent.interact_pressed = controller.wants_interact
