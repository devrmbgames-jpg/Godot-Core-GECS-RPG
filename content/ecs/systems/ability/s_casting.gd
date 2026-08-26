## Продвигает active cast logical work с учётом текущего AttackSpeed/CastSpeed.
## Local player во время windup продолжает обновлять aim к текущему cursor position.
extends System
class_name S_Casting


func query() -> QueryBuilder:
	return q.with_all([C_Casting, C_AttackSpeed, C_CastSpeed]).iterate([C_Casting, C_AttackSpeed, C_CastSpeed])


func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var castings: Array = components[0]
	var attack_speeds: Array = components[1]
	var cast_speeds: Array = components[2]
	for index in entities.size():
		var actor: Entity = entities[index]
		var casting: C_Casting = castings[index] as C_Casting
		if casting == null or not casting.active:
			continue
		if actor.has_component(C_Dead) or casting.ability == null or not is_instance_valid(casting.ability):
			casting.clear()
			continue
		if actor.has_component(C_PlayerController):
			var intent: C_ControllerIntent = actor.get_component(C_ControllerIntent) as C_ControllerIntent
			if intent != null:
				casting.target = null
				casting.target_position = intent.aim_world_position
		var speed: float = 1.0
		match casting.timing:
			AbilityDefinition.Timing.ATTACK:
				speed = (attack_speeds[index] as C_AttackSpeed).value
			AbilityDefinition.Timing.CAST:
				speed = (cast_speeds[index] as C_CastSpeed).value
		casting.remaining_work -= delta * maxf(speed, 0.0)
		if casting.remaining_work > 0.0:
			continue
		AbilityResolver.resolve(actor, casting.ability, casting.target, casting.target_position, cmd)
		casting.clear()
