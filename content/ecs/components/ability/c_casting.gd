## Длительный single-cast runtime state actor.
##
## [member remaining_work] уменьшается на delta * AttackSpeed/CastSpeed, поэтому
## изменение haste во время cast немедленно влияет на timeline.
extends Component
class_name C_Casting

var ability: Entity
var target: Entity
var target_position: Vector3 = Vector3.ZERO
var remaining_work: float = 0.0
var timing: int = AbilityDefinition.Timing.CAST


func _init(
	initial_ability: Entity = null,
	initial_target: Entity = null,
	initial_target_position: Vector3 = Vector3.ZERO,
	initial_work: float = 0.0,
	initial_timing: int = AbilityDefinition.Timing.CAST,
) -> void:
	ability = initial_ability
	target = initial_target
	target_position = initial_target_position
	remaining_work = initial_work
	timing = initial_timing
