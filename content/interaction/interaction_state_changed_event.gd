## Типизированный event изменения C_Activatable после InteractionRequest.
extends RefCounted
class_name InteractionStateChangedEvent

## Новое состояние C_Activatable.active.
var active: bool = false

## InteractionRequest, который вызвал изменение.
var request: InteractionRequest


func _init(initial_active: bool, initial_request: InteractionRequest) -> void:
	active = initial_active
	request = initial_request
