## Immutable request: actor пытается активировать target.
extends RefCounted
class_name InteractionRequest

var actor: Entity


## Создаёт request context; target задаётся адресатом targeted GECS event, а не полем payload.
func _init(initial_actor: Entity = null) -> void:
	actor = initial_actor
