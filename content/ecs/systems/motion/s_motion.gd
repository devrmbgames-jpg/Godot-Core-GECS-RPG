extends System
class_name S_Motion


func sub_systems() -> Array[Array]:
	return [
		[
			q.with_all(
				[C_MotionDirection, C_MotionSpeed, C_MotionAcceleration, C_IsCharacter]
			).iterate(
				[C_MotionDirection, C_MotionSpeed, C_MotionAcceleration]
			), process_kinematic_character
		],
		
		[
			q.with_all(
				[C_MotionDirection, C_MotionSpeed, C_MotionAcceleration, C_IsRigid]
			).iterate(
				[C_MotionDirection, C_MotionSpeed, C_MotionAcceleration]
			), process_rigid_character
		]
	]


func process_kinematic_character(entities: Array[Entity], components: Array, delta: float) -> void :
	var c_direction_list := components[0] as Array
	var c_speed_list := components[1] as Array
	var c_accel_list := components[2] as Array
	
	for idx in entities.size() :
		var c_direction := c_direction_list[idx] as C_MotionDirection
		var c_speed := c_speed_list[idx] as C_MotionSpeed
		var c_accel := c_accel_list[idx] as C_MotionAcceleration
		var entity := entities[idx]
		var character := entity as Node as CharacterBody3D
		
		var dir := c_direction.direction
		if dir.length_squared() > 0.01 :
			character.velocity.x = move_toward(character.velocity.x, dir.x * c_speed.speed, c_accel.acceleration * delta)
			character.velocity.z = move_toward(character.velocity.z, dir.z * c_speed.speed, c_accel.acceleration * delta)
		else :
			var friction := 100.0
			if entity.has_component(C_Friction) :
				var c_friction := entity.get_component(C_Friction) as C_Friction
				friction = c_friction.friction
			character.velocity.x = move_toward(character.velocity.x, 0.0, friction * delta )
			character.velocity.z = move_toward(character.velocity.z, 0.0, friction * delta)
			
		
	pass

func process_rigid_character(entities: Array[Entity], components: Array, delta: float) -> void :
	var c_direction_list := components[0] as Array
	var c_speed_list := components[1] as Array
	var c_accel_list := components[2] as Array
	
	for idx in entities.size() :
		var c_direction := c_direction_list[idx] as C_MotionDirection
		var c_speed := c_speed_list[idx] as C_MotionSpeed
		var c_accel := c_accel_list[idx] as C_MotionAcceleration
		var entity := entities[idx]
		var rigid := entity as Node as RigidBody3D
		
		var dir := c_direction.direction
		if dir.length_squared() > 0.01 :
			rigid.linear_velocity.x = move_toward(rigid.linear_velocity.x, dir.x * c_speed.speed, c_accel.acceleration * delta)
			rigid.linear_velocity.z = move_toward(rigid.linear_velocity.z, dir.z * c_speed.speed, c_accel.acceleration * delta)
		
		
	pass
