## Преобразует локальный InputMap в общий C_ControllerIntent.
##
## Система не двигает Entity и не вызывает abilities напрямую.
extends System
class_name S_InputPlayer


func query() -> QueryBuilder:
	return q.with_all([C_InputPlayer, C_ControllerIntent]).iterate([C_InputPlayer, C_ControllerIntent])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var inputs: Array = components[0]
	var intents: Array = components[1]
	for index in entities.size():
		var input_component := inputs[index] as C_InputPlayer
		var intent := intents[index] as C_ControllerIntent
		var profile := input_component.profile
		if profile == null:
			profile = InputProfile.new()
		var raw := Input.get_vector(
			profile.move_left,
			profile.move_right,
			profile.move_forward,
			profile.move_backward,
		)
		var direction := Vector3(raw.x, 0.0, raw.y)
		if input_component.camera_relative and direction.length_squared() > 0.0:
			var node3d := entities[index] as Node as Node3D
			var camera := node3d.get_viewport().get_camera_3d() if node3d != null else null
			if camera != null:
				var forward := camera.global_basis.z
				var right := camera.global_basis.x
				forward.y = 0.0
				right.y = 0.0
				forward = forward.normalized()
				right = right.normalized()
				direction = (forward * raw.y + right * raw.x)
		intent.move_direction = direction.limit_length(1.0)
		intent.facing_direction = intent.move_direction
		intent.primary_pressed = Input.is_action_just_pressed(profile.primary_action)
		intent.secondary_pressed = Input.is_action_just_pressed(profile.secondary_action)
		intent.interact_pressed = Input.is_action_just_pressed(profile.interact)
