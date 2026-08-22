## Periodic effect clock. Remaining уменьшается до следующего tick.
extends Component
class_name C_EffectTick

var interval: float = 1.0
var remaining: float = 1.0


func _init(initial_interval: float = 1.0) -> void:
	interval = maxf(initial_interval, 0.001)
	remaining = interval
