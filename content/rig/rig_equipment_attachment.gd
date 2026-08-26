## Runtime typed attachment конкретного equipment visual к semantic rig socket.
extends RefCounted
class_name RigEquipmentAttachment

var socket: StringName = &""
var visual: Node


## Создаёт runtime record socket -> instantiated visual Node; ownership visual остаётся у SceneTree.
func _init(initial_socket: StringName, initial_visual: Node) -> void:
	socket = initial_socket
	visual = initial_visual
