## Плавно поворачивает CharacterBody и RigidBody к Controller facing direction.
extends System
class_name S_Rotation


func sub_systems() -> Array[Array]:
	return [
		[
			q.with_all([C_IsCharacter, C_ControllerIntent, C_TurnSpeed]).iterate([C_ControllerIntent, C_TurnSpeed]),
			_process_character_rotation,
		],
		[
			q.with_all([C_IsRigid, C_ControllerIntent, C_TurnSpeed]).iterate([C_ControllerIntent, C_TurnSpeed]),
			_process_rigid_rotation,
		],
	]


func _wanted_direction(intent: C_ControllerIntent) -> Vector3:
	var direction := intent.facing_direction
	if direction.length_squared() <= 0.0001:
		direction = intent.move_direction
	direction.y = 0.0
	return direction.normalized() if direction.length_squared() > 0.0001 else Vector3.ZERO


func _process_character_rotation(entities: Array[Entity], components: Array, delta: float) -> void:
	var intents: Array = components[0]
	var turns: Array = components[1]
	for index in entities.size():
		var body := entities[index] as Node as Node3D
		var direction := _wanted_direction(intents[index] as C_ControllerIntent)
		if body == null or direction == Vector3.ZERO:
			continue
		var target_yaw := atan2(direction.x, direction.z) - PI
		body.global_rotation.y = rotate_toward(
			body.global_rotation.y,
			target_yaw,
			maxf((turns[index] as C_TurnSpeed).value, 0.0) * delta,
		)


func _process_rigid_rotation(entities: Array[Entity], components: Array, delta: float) -> void:
	var intents: Array = components[0]
	var turns: Array = components[1]
	for index in entities.size():
		var body := entities[index] as Node as RigidBody3D
		var direction := _wanted_direction(intents[index] as C_ControllerIntent)
		if body == null or direction == Vector3.ZERO:
			continue
		var target_yaw := atan2(direction.x, direction.z) - PI
		var error := wrapf(target_yaw - body.global_rotation.y, -PI, PI)
		var turn_strength := maxf((turns[index] as C_TurnSpeed).value, 0.0)
		var torque_y := error * turn_strength * body.mass - body.angular_velocity.y * body.mass * 2.0
		body.apply_torque(Vector3.UP * torque_y)
