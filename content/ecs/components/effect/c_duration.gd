## Remaining lifetime transient gameplay object/effect.
extends Component
class_name C_Duration

var remaining: float = 0.0


## Инициализирует remaining lifetime в секундах/logical time units consumer system-а.
func _init(initial_remaining: float = 0.0) -> void:
	remaining = initial_remaining
