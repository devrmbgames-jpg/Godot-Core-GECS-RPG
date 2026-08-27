## Prototype humanoid model/state-machine used as an art-side presentation endpoint.
##
## This Node does not own gameplay state. CharacterRig drives the semantic flags/methods,
## while AnimationTree method tracks emit timing signals such as attack start/finish.
@tool
extends Node3D
class_name PrototypeCharacterModel

## Emitted when the locomotion state is asked to walk.
signal anim_walk_started()
## Emitted when the locomotion state is asked to idle.
signal anim_idle_started()
## Emitted by the attack animation method track when the swing begins.
signal anim_attack_started()
## Emitted by the cast-start animation method track.
signal anim_cast_started()
## Emitted when an external presentation adapter requests cast interruption.
signal anim_cast_breaked()

## Emitted by the attack animation method track when the swing finishes.
signal anim_attack_finished()
## Emitted by the cast-finish animation method track.
signal anim_cast_finished()

@export var has_walk := false
@export var has_cast := false
@export var has_cast_break := false
@export var has_cast_completed := false
@export var has_attack := false

## Equipment anchor for the left hand.
@export var slot_arm_left: Node3D = null
## Equipment anchor for the right hand.
@export var slot_arm_right: Node3D = null
@export var animation_player: AnimationPlayer = null
@export var animation_tree: AnimationTree = null


## Activates the prototype AnimationTree explicitly so runtime behavior does not depend on editor state.
func _ready() -> void:
	if animation_tree != null:
		animation_tree.active = true


## Requests the AnimationTree locomotion transition to walk.
func play_walk() -> void:
	has_walk = true
	anim_walk_started.emit()


## Requests the AnimationTree locomotion transition to idle.
func play_idle() -> void:
	has_walk = false
	anim_idle_started.emit()


## Raises the one-shot attack flag; the animation method track clears it on finish.
func play_attack() -> void:
	has_attack = true


## Starts the cast_start -> cast_idle sequence and clears stale completion state.
func play_cast() -> void:
	has_cast_completed = false
	has_cast = true


## Allows the AnimationTree to leave cast_idle through cast_finish.
func complete_cast() -> void:
	has_cast_completed = true


## Requests an interrupted cast transition back to locomotion.
func play_cast_break() -> void:
	has_cast_break = true
	anim_cast_breaked.emit()


## Clears all prototype state-machine flags.
func reset() -> void:
	has_walk = false
	has_cast = false
	has_cast_break = false
	has_cast_completed = false
	has_attack = false


## Animation method-track callback: clears cast completion/request flags and emits completion.
func on_cast_finished() -> void:
	has_cast_completed = false
	has_cast = false
	anim_cast_finished.emit()


## Animation method-track callback: consumes the initial cast request and emits cast start.
func on_cast_started() -> void:
	has_cast = false
	anim_cast_started.emit()


## Animation method-track hook reserved for future cast-idle presentation timing.
func on_cast_idle() -> void:
	pass


## Animation method-track callback used by rig adapters to start weapon swing VFX.
func on_attack_started() -> void:
	anim_attack_started.emit()


## Animation method-track callback: clears attack flag and signals weapon swing completion.
func on_attack_finished() -> void:
	has_attack = false
	anim_attack_finished.emit()


## Animation method-track callback: clears any pending cast-break flag after reaching idle.
func on_idle() -> void:
	has_cast_break = false


## Animation method-track callback: clears any pending cast-break flag after reaching walk.
func on_walk() -> void:
	has_cast_break = false
