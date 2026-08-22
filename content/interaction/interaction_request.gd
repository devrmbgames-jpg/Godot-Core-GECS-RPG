## Immutable request: actor пытается активировать target.
extends RefCounted
class_name InteractionRequest

var actor: Entity


func _init(initial_actor: Entity = null) -> void:
	actor = initial_actor
