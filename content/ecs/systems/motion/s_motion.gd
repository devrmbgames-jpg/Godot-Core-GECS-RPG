## Locomotion motor для CharacterBody3D и RigidBody3D.
##
## Physical velocity остаётся authority Godot body. В combat state движение назад
## относительно aim/facing плавно замедляется через C_CombatState multiplier.
extends System
class_name S_Motion


## Регистрирует отдельные CharacterBody/RigidBody queries с соответствующими motor callbacks.
func sub_systems() -> Array[Array]:
	return [
		[
			q.with_all([
				C_IsCharacter, C_ControllerIntent, C_MoveSpeed, C_Acceleration,
				C_Deceleration, C_MotorState, C_ExternalMotion,
			]).with_none([C_Dead]).iterate([
				C_ControllerIntent, C_MoveSpeed, C_Acceleration,
				C_Deceleration, C_MotorState, C_ExternalMotion,
			]),
			_process_character_motor,
		],
		[
			q.with_all([
				C_IsRigid, C_ControllerIntent, C_MoveSpeed, C_Acceleration, C_Deceleration,
			]).with_none([C_Dead]).iterate([C_ControllerIntent, C_MoveSpeed, C_Acceleration, C_Deceleration]),
			_process_rigid_motor,
		],
	]


## Обновляет только controlled horizontal contribution CharacterBody и складывает её с external motion.
func _process_character_motor(entities: Array[Entity], components: Array, delta: float) -> void:
	var intents: Array = components[0]
	var speeds: Array = components[1]
	var accelerations: Array = components[2]
	var decelerations: Array = components[3]
	var motor_states: Array = components[4]
	var external_states: Array = components[5]
	for index in entities.size():
		var actor: Entity = entities[index]
		var body := actor as Node as CharacterBody3D
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
		var resolved_speed: float = _movement_speed(actor, intent, speed.value)
		var target := direction * resolved_speed
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


## Сервит горизонтальную RigidBody velocity к desired target через force, не overwrite linear_velocity.
func _process_rigid_motor(entities: Array[Entity], components: Array, delta: float) -> void:
	if delta <= 0.0:
		return
	var intents: Array = components[0]
	var speeds: Array = components[1]
	var accelerations: Array = components[2]
	var decelerations: Array = components[3]
	for index in entities.size():
		var actor: Entity = entities[index]
		var body := actor as Node as RigidBody3D
		if body == null:
			continue
		var intent := intents[index] as C_ControllerIntent
		var direction := intent.move_direction
		direction.y = 0.0
		direction = direction.limit_length(1.0)
		var base_speed: float = (speeds[index] as C_MoveSpeed).value
		var speed: float = _movement_speed(actor, intent, base_speed)
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


## Возвращает target speed с плавным backpedal penalty по dot(move, facing) только в combat state.
func _movement_speed(actor: Entity, intent: C_ControllerIntent, base_speed: float) -> float:
	var state: C_CombatState = actor.get_component(C_CombatState) as C_CombatState
	if state == null or not state.active:
		return base_speed
	var move: Vector3 = intent.move_direction
	var facing: Vector3 = intent.facing_direction
	move.y = 0.0
	facing.y = 0.0
	if move.length_squared() <= 0.0001 or facing.length_squared() <= 0.0001:
		return base_speed
	var dot: float = move.normalized().dot(facing.normalized())
	var backward_weight: float = clampf(-dot, 0.0, 1.0)
	return base_speed * lerpf(1.0, state.backpedal_speed_multiplier, backward_weight)
