## Помечает Entity как локально управляемую через Godot InputMap.
##
## [member profile] задаёт semantic action names; actual bindings остаются в InputMap.
extends Component
class_name C_InputPlayer

@export var profile: InputProfile
@export var camera_relative: bool = true


func _init(initial_profile: InputProfile = null) -> void:
	profile = initial_profile if initial_profile != null else InputProfile.new()
