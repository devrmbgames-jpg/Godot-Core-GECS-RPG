extends System
class_name S_Rotation


func query() -> QueryBuilder:
	return q.with_all([C_Rotation, C_MotionDirection]).iterate([C_Rotation, C_MotionDirection])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var c_rotation_list := components[0] as Array
	var c_direction_list := components[1] as Array
	for idx in entities.size() :
		var c_rotation := c_rotation_list[idx] as C_Rotation
		var c_direction := c_direction_list[idx] as C_MotionDirection
		var entity := entities[idx]
		var node3d := entity as Node as Node3D
		if node3d :
			var dir := c_direction.direction
			if dir.length_squared() > 0.0:
				# Calculate target angle on the XZ plane
				var target_angle := atan2(dir.x, dir.z) - PI
				# Smoothly rotate by a fixed step towards the target angle
				node3d.global_rotation.y = rotate_toward(node3d.global_rotation.y, target_angle, c_rotation.rotation_speed * delta)
