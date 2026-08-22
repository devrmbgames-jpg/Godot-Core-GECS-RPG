## Пример AI behavior: преследует target и запрашивает primary ability в радиусе атаки.
extends System
class_name S_AIChase


func query() -> QueryBuilder:
	return q.with_all([C_AIController, C_AIChase, C_CombatTarget]).with_none([C_Dead]).iterate([C_AIController, C_AIChase, C_CombatTarget])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var controllers: Array = components[0]
	var chases: Array = components[1]
	var combat_targets: Array = components[2]
	for index in entities.size():
		var actor_node := entities[index] as Node as Node3D
		var controller := controllers[index] as C_AIController
		var chase := chases[index] as C_AIChase
		var combat_target := combat_targets[index] as C_CombatTarget
		if actor_node == null or chase.target == null or not is_instance_valid(chase.target):
			controller.desired_move_direction = Vector3.ZERO
			combat_target.target = null
			continue
		var target_node := chase.target as Node as Node3D
		if target_node == null:
			continue
		var offset := target_node.global_position - actor_node.global_position
		offset.y = 0.0
		var distance := offset.length()
		var direction := offset.normalized() if distance > 0.001 else Vector3.ZERO
		controller.desired_facing_direction = direction
		controller.desired_move_direction = direction if distance > chase.stop_distance else Vector3.ZERO
		combat_target.target = chase.target
		if distance <= chase.attack_distance:
			controller.wants_primary = true
