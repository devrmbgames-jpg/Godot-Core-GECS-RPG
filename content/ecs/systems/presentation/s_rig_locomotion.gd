## Отражает actual Godot body velocity в locomotion presentation CharacterRig.
## Никаких зеркальных C_Velocity/C_Position не создаётся.
extends System
class_name S_RigLocomotion


## Регистрирует presentation readback отдельно для CharacterBody и RigidBody actors.
func sub_systems() -> Array[Array]:
	return [
		[q.with_all([C_IsCharacter, C_MoveSpeed]).iterate([C_MoveSpeed]), _process_character],
		[q.with_all([C_IsRigid, C_MoveSpeed]).iterate([C_MoveSpeed]), _process_rigid],
	]


## Читает CharacterBody.get_real_velocity(), нормализует к MoveSpeed и обновляет rig locomotion/grounded.
func _process_character(entities: Array[Entity], components: Array, _delta: float) -> void:
	var speeds: Array = components[0]
	for index in entities.size():
		var body := entities[index] as Node as CharacterBody3D
		var rig := RigLocator.find(entities[index])
		if body == null or rig == null:
			continue
		var horizontal := body.get_real_velocity()
		horizontal.y = 0.0
		var max_speed := maxf((speeds[index] as C_MoveSpeed).value, 0.001)
		rig.set_locomotion(horizontal.length() / max_speed, body.is_on_floor())


## Читает RigidBody.linear_velocity и обновляет rig locomotion без ECS-копии velocity.
func _process_rigid(entities: Array[Entity], components: Array, _delta: float) -> void:
	var speeds: Array = components[0]
	for index in entities.size():
		var body := entities[index] as Node as RigidBody3D
		var rig := RigLocator.find(entities[index])
		if body == null or rig == null:
			continue
		var horizontal := body.linear_velocity
		horizontal.y = 0.0
		var max_speed := maxf((speeds[index] as C_MoveSpeed).value, 0.001)
		rig.set_locomotion(horizontal.length() / max_speed, false)
