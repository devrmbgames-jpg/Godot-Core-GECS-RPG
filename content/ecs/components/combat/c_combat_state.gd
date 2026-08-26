## Runtime combat stance/lifetime state actor-а.
##
## Combat state остаётся active, пока есть nearby enemies или не истёк linger timer
## после offensive ability / direct damage.
extends Component
class_name C_CombatState

@export var sensor_path: NodePath = ^"CombatSensor"
@export_range(0.0, 30.0, 0.1) var linger_duration: float = 4.0
@export_range(0.1, 1.0, 0.05) var backpedal_speed_multiplier: float = 0.75

var active: bool = false
var remaining: float = 0.0
var nearby_enemy_count: int = 0


func refresh(duration: float = -1.0) -> void:
	active = true
	var resolved_duration: float = linger_duration if duration < 0.0 else duration
	remaining = maxf(remaining, maxf(resolved_duration, 0.0))


func clear() -> void:
	active = false
	remaining = 0.0
	nearby_enemy_count = 0
