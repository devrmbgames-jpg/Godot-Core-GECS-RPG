## Снимает Godot InputMap в C_InputState. Не знает camera, Motion или Ability.
extends System
class_name S_InputPlayer


func query() -> QueryBuilder:
	return q.with_all([C_InputPlayer, C_InputState]).iterate([C_InputPlayer, C_InputState])


func process(_entities: Array[Entity], components: Array, _delta: float) -> void:
	var inputs: Array = components[0]
	var states: Array = components[1]
	for index in inputs.size():
		var input_component := inputs[index] as C_InputPlayer
		var state := states[index] as C_InputState
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
