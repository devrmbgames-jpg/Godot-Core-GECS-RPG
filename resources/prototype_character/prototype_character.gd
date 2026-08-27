@tool
extends Node3D

signal anim_walk_started()
signal anim_idle_started()
signal anim_attack_started()
signal anim_cast_started()
signal anim_cast_breaked()

signal anim_attack_finished()
signal anim_cast_finished()

@export var has_walk := false
@export var has_cast := false
@export var has_cast_break := false
@export var has_cast_completed := false
@export var has_attack := false


@export var slot_arm_left: Node3D = null
@export var slot_arm_right: Node3D = null
@export var animation_player: AnimationPlayer = null
@export var animation_tree: AnimationTree = null

func play_walk() -> void :
	has_walk = true
	anim_walk_started.emit()

func play_idle() -> void :
	has_walk = false
	anim_idle_started.emit()

func play_attack() -> void :
	has_attack = true

func play_cast() -> void :
	has_cast = true

func play_cast_break() -> void :
	has_cast_break = true
	anim_cast_breaked.emit()

func reset() -> void :
	has_walk = false
	has_cast = false
	has_cast_break = false
	has_cast_completed = false
	has_attack = false


func on_cast_finished() -> void :
	has_cast_completed = false
	has_cast = false
	anim_cast_finished.emit()

func on_cast_started() -> void :
	has_cast = false
	anim_cast_started.emit()

func on_cast_idle() -> void :
	pass

func on_attack_started() -> void :
	anim_attack_started.emit()

func on_attack_finished() -> void :
	has_attack = false
	anim_attack_finished.emit()

func on_idle() -> void :
	has_cast_break = false

func on_walk() -> void :
	has_cast_break = false
