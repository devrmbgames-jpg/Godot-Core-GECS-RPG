## На interact intent ищет ближайшую видимую Entity raycast'ом и создаёт request.
extends System
class_name S_InteractionIntent


func query() -> QueryBuilder:
	return q.with_all([C_ControllerIntent, C_InteractionRange]).iterate([C_ControllerIntent, C_InteractionRange])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var intents: Array = components[0]
	var ranges: Array = components[1]
	for index in entities.size():
		var intent := intents[index] as C_ControllerIntent
		if not intent.interact_pressed:
			continue
		var actor := entities[index]
		var actor_node := actor as Node as Node3D
		if actor_node == null:
			continue
		var origin := actor_node.global_position + Vector3.UP
		var direction := CombatQuery.facing(actor)
		var hit: CombatHit = CombatQuery.raycast_entity(
			actor,
			origin,
			origin + direction * maxf((ranges[index] as C_InteractionRange).value, 0.0),
		)
		var target := hit.entity if hit != null else null
		if target != null and target.has_component(C_Interactable):
			InteractionService.request(actor, target)
