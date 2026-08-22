## Адаптер-конфигурация semantic gameplay actions к конкретному animation rig.
extends Resource
class_name RigProfile

@export var action_map: Dictionary = {}
@export var state_machine_playback_path: StringName = &"parameters/playback"
@export var locomotion_blend_path: StringName = &""
@export var socket_paths: Dictionary = {}


func action_name(action: StringName) -> StringName:
	return StringName(action_map.get(action, action))


func socket_path(socket: StringName) -> NodePath:
	return NodePath(str(socket_paths.get(socket, "")))
