## Адаптер-конфигурация semantic gameplay actions к конкретному animation rig.
extends Resource
class_name RigProfile

## Dictionary[StringName semantic_action, StringName animation_or_state_name].
@export var action_map: Dictionary = {}

## Property AnimationTree, возвращающее AnimationNodeStateMachinePlayback.
@export var state_machine_playback_path: StringName = &"parameters/playback"

## Опциональный float property AnimationTree для locomotion 0..1.
@export var locomotion_blend_path: StringName = &""

## Dictionary[StringName semantic_socket, NodePath relative_to_model_root].
@export var socket_paths: Dictionary = {}


func action_name(action: StringName) -> StringName:
	return StringName(action_map.get(action, action))


func socket_path(socket: StringName) -> NodePath:
	var value: Variant = socket_paths.get(socket, NodePath())
	return value as NodePath
