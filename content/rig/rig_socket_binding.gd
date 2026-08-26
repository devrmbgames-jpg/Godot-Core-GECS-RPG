## Один typed mapping semantic equipment socket -> NodePath конкретного rig/model.
extends Resource
class_name RigSocketBinding

@export var socket: StringName = &""
@export var path: NodePath


## Создаёт typed semantic socket mapping для RigProfile.
func _init(initial_socket: StringName = &"", initial_path: NodePath = NodePath()) -> void:
	socket = initial_socket
	path = initial_path
