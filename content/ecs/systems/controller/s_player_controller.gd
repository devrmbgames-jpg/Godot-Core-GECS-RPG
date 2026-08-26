## Преобразует C_InputState локального игрока в world-space movement/aim intent.
extends System
class_name S_PlayerController


## Выбирает живых local-player actors с device snapshot и common controller output.
func query() -> QueryBuilder:
	return q.with_all([C_PlayerController, C_InputState, C_ControllerIntent]).with_none([C_Dead]).iterate([C_PlayerController, C_InputState, C_ControllerIntent])


## Конвертирует camera-relative movement, cursor aim и action flags в C_ControllerIntent.
## В combat state или при ability press facing следует aim; вне боя — movement direction.
func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var controllers: Array = components[0]
	var states: Array = components[1]
	var intents: Array = components[2]
	for index in entities.size():
		var actor: Entity = entities[index]
		var controller: C_PlayerController = controllers[index] as C_PlayerController
		var state: C_InputState = states[index] as C_InputState
		var intent: C_ControllerIntent = intents[index] as C_ControllerIntent
		var actor_node: Node3D = actor as Node as Node3D
		var camera: Camera3D = actor_node.get_viewport().get_camera_3d() if actor_node != null else null
		var direction := Vector3(state.move_axis.x, 0.0, state.move_axis.y)
		if controller.camera_relative and camera != null and direction.length_squared() > 0.0:
			var forward := camera.global_basis.z
			var right := camera.global_basis.x
			forward.y = 0.0
			right.y = 0.0
			forward = forward.normalized()
			right = right.normalized()
			direction = forward * state.move_axis.y + right * state.move_axis.x
		intent.move_direction = direction.limit_length(1.0)
		_update_cursor_aim(actor_node, camera, state.pointer_position, intent)
		var combat_state: C_CombatState = actor.get_component(C_CombatState) as C_CombatState
		var ability_pressed: bool = state.primary_pressed or state.secondary_pressed or state.skill_1_pressed
		if (combat_state != null and combat_state.active) or ability_pressed:
			intent.facing_direction = intent.aim_direction if intent.aim_direction.length_squared() > 0.0001 else intent.move_direction
		else:
			intent.facing_direction = intent.move_direction
		intent.primary_pressed = state.primary_pressed
		intent.secondary_pressed = state.secondary_pressed
		intent.skill_1_pressed = state.skill_1_pressed
		intent.interact_pressed = state.interact_pressed


## Проецирует viewport pointer ray на горизонтальную plane actor-а; physics world query не выполняется.
func _update_cursor_aim(actor: Node3D, camera: Camera3D, pointer: Vector2, intent: C_ControllerIntent) -> void:
	if actor == null or camera == null:
		intent.aim_direction = Vector3.ZERO
		return
	var ray_origin: Vector3 = camera.project_ray_origin(pointer)
	var ray_direction: Vector3 = camera.project_ray_normal(pointer)
	var actor_plane := Plane(Vector3.UP, actor.global_position.y)
	var intersection: Variant = actor_plane.intersects_ray(ray_origin, ray_direction)
	if intersection == null:
		intent.aim_direction = Vector3.ZERO
		return
	var aim_position: Vector3 = intersection
	var aim_direction: Vector3 = aim_position - actor.global_position
	aim_direction.y = 0.0
	intent.aim_world_position = aim_position
	intent.aim_direction = aim_direction.normalized() if aim_direction.length_squared() > 0.0001 else Vector3.ZERO
