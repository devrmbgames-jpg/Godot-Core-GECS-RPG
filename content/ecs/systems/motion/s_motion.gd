## Locomotion motor для CharacterBody3D и RigidBody3D.
##
## CharacterBody: вычисляет только управляемую horizontal velocity и складывает её
## с C_ExternalMotion; actual body.velocity остаётся physical authority.
## RigidBody: прикладывает force к target velocity вместо перезаписи linear_velocity,
## поэтому внешние силы и collision impulses сохраняются.
extends System
class_name S_Motion


func sub_systems() -> Array[Array]:
	return [
		[
			q.with_all([
				C_IsCharacter, C_ControllerIntent, C_MoveSpeed, C_Acceleration,
				C_Deceleration, C_MotorState, C_ExternalMotion,
			]).iterate([
				C_ControllerIntent, C_MoveSpeed, C_Acceleration,
				C_Deceleration, C_MotorState, C_ExternalMotion,
			]),
			_process_character_motor,
		],
		[
			q.with_all([
				C_IsRigid, C_ControllerIntent, C_MoveSpeed, C_Acceleration, C_Deceleration,
			]).iterate([C_ControllerIntent, C_MoveSpeed, C_Acceleration, C_Deceleration]),
			_process_rigid_motor,
		],
	]


func _process_character_motor(entities: Array[Entity], components: Array, delta: float) -> void:
	var intents: Array = components[0]
	var speeds: Array = components[1]
	var accelerations: Array = components[2]
	var decelerations: Array = components[3]
	var motor_states: Array = components[4]
	var external_states: Array = components[5]
	for index in entities.size():
		var body := entities[index] as Node as CharacterBody3D
		if body == null:
			continue
		var intent := intents[index] as C_ControllerIntent
		var speed := speeds[index] as C_MoveSpeed
		var acceleration := accelerations[index] as C_Acceleration
		var deceleration := decelerations[index] as C_Deceleration
		var motor := motor_states[index] as C_MotorState
		var external := external_states[index] as C_ExternalMotion
		var direction := intent.move_direction
		direction.y = 0.0
		direction = direction.limit_length(1.0)
		var target := direction * speed.value
		var rate := acceleration.value if direction.length_squared() > 0.0001 else deceleration.value
		motor.controlled_velocity = motor.controlled_velocity.move_toward(target, maxf(rate, 0.0) * delta)
		motor.controlled_velocity.y = 0.0
		external.horizontal_velocity = external.horizontal_velocity.move_toward(
			Vector3.ZERO,
			maxf(external.damping, 0.0) * delta,
		)
		var horizontal := motor.controlled_velocity + external.horizontal_velocity
		body.velocity.x = horizontal.x
		body.velocity.z = horizontal.z


func _process_rigid_motor(entities: Array[Entity], components: Array, delta: float) -> void:
	if delta <= 0.0:
		return
	var intents: Array = components[0]
	var speeds: Array = components[1]
	var accelerations: Array = components[2]
	var decelerations: Array = components[3]
	for index in entities.size():
		var body := entities[index] as Node as RigidBody3D
		if body == null:
			continue
		var intent := intents[index] as C_ControllerIntent
		var direction := intent.move_direction
		direction.y = 0.0
		direction = direction.limit_length(1.0)
		var speed := (speeds[index] as C_MoveSpeed).value
		var rate := (
			(accelerations[index] as C_Acceleration).value
			if direction.length_squared() > 0.0001
			else (decelerations[index] as C_Deceleration).value
		)
		var current := Vector3(body.linear_velocity.x, 0.0, body.linear_velocity.z)
		var target := direction * speed
		var delta_velocity := target - current
		var max_delta := maxf(rate, 0.0) * delta
		if delta_velocity.length() > max_delta and max_delta > 0.0:
			delta_velocity = delta_velocity.normalized() * max_delta
		var acceleration_vector := delta_velocity / delta
		body.apply_central_force(acceleration_vector * body.mass)
