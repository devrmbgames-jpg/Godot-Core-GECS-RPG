## CharacterRig adapter for resources/prototype_character/prototype_character.tscn.
##
## Keeps CharacterBody3D/ECS as actor authority while translating semantic presentation
## actions into the prototype model's AnimationTree flags and arm-slot references.
extends CharacterRig
class_name PrototypeCharacterRig

## Minimum normalized locomotion speed that switches the prototype model to walk.
@export_range(0.0, 1.0, 0.01) var walk_threshold: float = 0.05

var _model: PrototypeCharacterModel
var _walking: bool = false


## Builds the model through CharacterRig and wires animation timing signals for weapon VFX.
func _ready() -> void:
	super._ready()
	_model = model_root as PrototypeCharacterModel
	if _model == null:
		return
	_walking = _model.has_walk
	_model.anim_attack_started.connect(_on_attack_started)
	_model.anim_attack_finished.connect(_on_attack_finished)


## Maps semantic attack/cast phases to the prototype AnimationTree control API.
##
## Fireball `start` enters cast_start/cast_idle; `resolve` releases cast_finish.
func play_action(action: StringName, phase: StringName = &"start") -> void:
	if _model == null:
		super.play_action(action, phase)
		return
	match action:
		&"attack":
			if phase == &"start":
				_model.play_attack()
		&"cast_fireball":
			if phase == &"start":
				_model.play_cast()
			elif phase == &"resolve":
				_model.complete_cast()
		_:
			super.play_action(action, phase)


## Converts normalized actual body speed into the prototype idle/walk state flags.
func set_locomotion(speed_ratio: float, grounded: bool) -> void:
	super.set_locomotion(speed_ratio, grounded)
	if _model == null:
		return
	var should_walk := grounded and speed_ratio > walk_threshold
	if should_walk == _walking:
		return
	_walking = should_walk
	if should_walk:
		_model.play_walk()
	else:
		_model.play_idle()


## Resolves semantic hand sockets directly from the typed prototype model, then falls back to RigProfile.
func get_socket(socket: StringName) -> Node:
	if _model != null:
		if (socket == &"main_hand" or socket == &"right_hand") and _model.slot_arm_right != null:
			return _model.slot_arm_right
		if (socket == &"off_hand" or socket == &"left_hand") and _model.slot_arm_left != null:
			return _model.slot_arm_left
	return super.get_socket(socket)


## Starts the trail exactly when the attack animation method track begins its swing.
func _on_attack_started() -> void:
	_set_main_hand_trail(true)


## Stops the trail when the attack animation method track reports completion.
func _on_attack_finished() -> void:
	_set_main_hand_trail(false)


## Toggles trail capability on the currently attached prototype sword, if present.
func _set_main_hand_trail(enabled: bool) -> void:
	var socket := get_socket(&"main_hand")
	if socket == null:
		return
	for child in socket.get_children():
		var sword := child as PrototypeSword
		if sword != null:
			sword.set_enable_trail(enabled)
