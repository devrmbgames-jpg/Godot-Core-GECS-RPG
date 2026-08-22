## Минимальная AI chase/attack behavior configuration.
extends Component
class_name C_AIChase

var target: Entity
@export var stop_distance: float = 1.7
@export var attack_distance: float = 2.5


func _init(initial_target: Entity = null) -> void:
	target = initial_target
