## Адаптер-конфигурация semantic gameplay actions к конкретному animation rig.
##
## Mappings хранятся typed Resources, а не Dictionary: ошибки action/socket names
## видимы в Inspector и рефакторятся без строковых value-contracts.
extends Resource
class_name RigProfile

@export var action_bindings: Array[RigActionBinding] = []
@export var state_machine_playback_path: StringName = &"parameters/playback"
@export var locomotion_blend_path: StringName = &""
@export var socket_bindings: Array[RigSocketBinding] = []


## Возвращает animation/state name для semantic action; без binding сохраняет исходное имя.
func action_name(action: StringName) -> StringName:
	for binding in action_bindings:
		if binding != null and binding.action == action:
			return binding.animation if binding.animation != &"" else action
	return action


## Возвращает model-relative NodePath semantic equipment socket или пустой NodePath.
func socket_path(socket: StringName) -> NodePath:
	for binding in socket_bindings:
		if binding != null and binding.socket == socket:
			return binding.path
	return NodePath()
