## Visible fallback Rig для primitive/prototype actors.
##
## Реализует тот же CharacterRig contract, что и импортированная модель, но вместо
## AnimationTree показывает locomotion/action небольшим procedural squash/bob.
## Благодаря этому playground визуально проверяет presentation bridge без art assets.
extends CharacterRig
class_name PrimitiveCharacterRig

@export var visual_path: NodePath = NodePath("../Visual")
@export var locomotion_bob_height: float = 0.06
@export var action_pulse_seconds: float = 0.18

var _visual: Node3D
var _base_position: Vector3
var _base_scale: Vector3
var _speed_ratio: float = 0.0
var _pulse_remaining: float = 0.0


## Инициализирует base CharacterRig и кеширует исходный transform primitive visual.
func _ready() -> void:
	super._ready()
	_visual = get_node_or_null(visual_path) as Node3D
	if _visual != null:
		_base_position = _visual.position
		_base_scale = _visual.scale


## Делегирует semantic action базовому rig и запускает короткий procedural pulse для demo phases.
func play_action(action: StringName, phase: StringName = &"start") -> void:
	super.play_action(action, phase)
	if phase == &"start" or phase == &"resolve" or phase == &"interact":
		_pulse_remaining = action_pulse_seconds


## Делегирует locomotion базовому rig и кеширует grounded speed ratio для procedural bob.
func set_locomotion(speed_ratio: float, grounded: bool) -> void:
	super.set_locomotion(speed_ratio, grounded)
	_speed_ratio = clampf(speed_ratio, 0.0, 1.0) if grounded else 0.0


## Обновляет исключительно demo visual transform; gameplay/physics actor transform не меняется.
func _process(delta: float) -> void:
	if _visual == null:
		return
	_pulse_remaining = maxf(0.0, _pulse_remaining - delta)
	var pulse_ratio := _pulse_remaining / action_pulse_seconds if action_pulse_seconds > 0.0 else 0.0
	var pulse := sin(pulse_ratio * PI) * 0.16
	var time := Time.get_ticks_msec() * 0.001
	_visual.position = _base_position + Vector3.UP * sin(time * 10.0) * locomotion_bob_height * _speed_ratio
	_visual.scale = Vector3(
		_base_scale.x * (1.0 + pulse),
		_base_scale.y * (1.0 - pulse * 0.45),
		_base_scale.z * (1.0 + pulse),
	)
