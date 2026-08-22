## Помечает Entity как локальный источник device input через Godot InputMap.
##
## Компонент выбирает InputProfile; перевод input в world-space выполняет Player Controller.
extends Component
class_name C_InputPlayer

@export var profile: InputProfile


func _init(initial_profile: InputProfile = null) -> void:
	profile = initial_profile if initial_profile != null else InputProfile.new()
