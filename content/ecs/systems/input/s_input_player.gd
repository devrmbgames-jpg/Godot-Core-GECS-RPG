## Снимает Godot InputMap и pointer position в C_InputState.
## Camera/world-space conversion остаётся ответственностью Player Controller.
extends System
class_name S_InputPlayer


func query() -> QueryBuilder:
	return q.with_all([C_InputPlayer, C_InputState]).iterate([C_InputPlayer, C_InputState])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var inputs: Array = components[0]
	var states: Array = components[1]
	for index in inputs.size():
		var state := states[index] as C_InputState
		var actor_node: Node = entities[index] as Node
		if actor_node != null:
			state.pointer_position = actor_node.get_viewport().get_mouse_position()
		if entities[index].has_component(C_Dead):
			state.move_axis = Vector2.ZERO
			state.primary_pressed = false
			state.secondary_pressed = false
			state.skill_1_pressed = false
			state.interact_pressed = false
			continue
		var input_component := inputs[index] as C_InputPlayer
		var profile := input_component.profile
		if profile == null:
			profile = InputProfile.new()
			input_component.profile = profile
		InputBindingService.ensure_profile(profile)
		state.move_axis = Input.get_vector(profile.move_left, profile.move_right, profile.move_forward, profile.move_backward)
		state.primary_pressed = Input.is_action_just_pressed(profile.primary_action)
		state.secondary_pressed = Input.is_action_just_pressed(profile.secondary_action)
		state.skill_1_pressed = Input.is_action_just_pressed(profile.skill_1_action)
		state.interact_pressed = Input.is_action_just_pressed(profile.interact)
