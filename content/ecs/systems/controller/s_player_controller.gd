## Преобразует C_InputState локального игрока в общий world-space C_ControllerIntent.
extends System
class_name S_PlayerController


func query() -> QueryBuilder:
	return q.with_all([C_PlayerController, C_InputState, C_ControllerIntent]).iterate([C_PlayerController, C_InputState, C_ControllerIntent])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var controllers: Array = components[0]
	var states: Array = components[1]
	var intents: Array = components[2]
	for index in entities.size():
		var controller := controllers[index] as C_PlayerController
		var state := states[index] as C_InputState
		var intent := intents[index] as C_ControllerIntent
		var direction := Vector3(state.move_axis.x, 0.0, state.move_axis.y)
		if controller.camera_relative and direction.length_squared() > 0.0:
			var node3d := entities[index] as Node as Node3D
			var camera := node3d.get_viewport().get_camera_3d() if node3d != null else null
			if camera != null:
				var forward := camera.global_basis.z
				var right := camera.global_basis.x
				forward.y = 0.0
				right.y = 0.0
				forward = forward.normalized()
				right = right.normalized()
				direction = forward * state.move_axis.y + right * state.move_axis.x
		intent.move_direction = direction.limit_length(1.0)
		intent.facing_direction = intent.move_direction
		intent.primary_pressed = state.primary_pressed
		intent.secondary_pressed = state.secondary_pressed
		intent.skill_1_pressed = state.skill_1_pressed
		intent.interact_pressed = state.interact_pressed
