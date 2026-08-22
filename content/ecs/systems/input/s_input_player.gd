extends System
class_name S_InputPlayer

func sub_systems() -> Array[Array]:
	return [
		[
			q.with_all(
				[C_MotionDirection, C_InputPlayer]
			).iterate(
				[C_MotionDirection]
			), process_input_direction
		]
	]


func process_input_direction(entities: Array[Entity], components: Array, _delta: float) -> void :
	var c_motion_direction_list := components[0] as Array
	for idx in entities.size() :
		var c_motion_direction := c_motion_direction_list[idx] as C_MotionDirection
		var entity := entities[0] as Node as Node3D
		
		var input_direction := Input.get_vector(
			&"game_move_left", &"game_move_right",
			&"game_move_forward", &"game_move_backward"
		)
		
		var direction := Vector3(
			input_direction.x,
			0.0,
			input_direction.y
		)
		var camera := entity.get_viewport().get_camera_3d()
		if camera :
			var camera_basis := camera.global_transform.basis # Adjust path to your camera node
			
			var camera_forward := camera_basis.z
			var camera_right := camera_basis.x
			camera_forward.y = 0.0
			camera_forward = camera_forward.normalized()
			camera_right.y = 0.0
			camera_right = camera_right.normalized()
			direction = (camera_forward * input_direction.y + camera_right * input_direction.x).normalized() * input_direction.length()
		
		#direction = direction.rotated(Vector3.UP, entity.rotation.y)
		c_motion_direction.direction = direction
