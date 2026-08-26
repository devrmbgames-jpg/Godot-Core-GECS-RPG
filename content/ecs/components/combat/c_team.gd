## Gameplay team/faction marker для базовых ally/enemy rules.
extends Component
class_name C_Team

@export var team_id: StringName = &"neutral"
## Позволяет временно исключить Entity из combat rules без изменения team identity.
@export var combat_enabled: bool = true


func _init(initial_team_id: StringName = &"neutral") -> void:
	team_id = initial_team_id
