## Реагирует на первый C_Dead add и разрывает control/cast state actor.
extends Observer
class_name O_Death


func query() -> QueryBuilder:
	return q.with_all([C_Dead]).on_added()


func each(_event: Variant, actor: Entity, _payload: Variant = null) -> void:
	var intent := actor.get_component(C_ControllerIntent) as C_ControllerIntent
	if intent != null:
		intent.move_direction = Vector3.ZERO
		intent.facing_direction = Vector3.ZERO
		intent.primary_pressed = false
		intent.secondary_pressed = false
		intent.skill_1_pressed = false
		intent.interact_pressed = false
	var motor := actor.get_component(C_MotorState) as C_MotorState
	if motor != null:
		motor.controlled_velocity = Vector3.ZERO
	if actor.has_component(C_Casting):
		cmd.remove_component(actor, C_Casting)
	ECS.world.emit_event(&"presentation_action", actor, {"action": &"death", "phase": &"start"})
	ECS.world.emit_event(&"actor_died", actor, null)
