## Постоянный runtime-state текущего cast/attack actor.
##
## Компонент живёт на actor постоянно: frequent abilities меняют поля, а не archetype.
## [member remaining_work] уменьшается на delta * AttackSpeed/CastSpeed.
extends Component
class_name C_Casting

var active: bool = false
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
	if initial_ability != null:
		start(initial_ability, initial_target, initial_target_position, initial_work, initial_timing)


## Начинает новый cast без structural add/remove component.
func start(
	new_ability: Entity,
	new_target: Entity,
	new_target_position: Vector3,
	work: float,
	new_timing: int,
) -> void:
	active = true
	ability = new_ability
	target = new_target
	target_position = new_target_position
	remaining_work = maxf(work, 0.0)
	timing = new_timing


## Сбрасывает runtime state, сохраняя сам Component на actor.
func clear() -> void:
	active = false
	ability = null
	target = null
	target_position = Vector3.ZERO
	remaining_work = 0.0
	timing = AbilityDefinition.Timing.CAST
