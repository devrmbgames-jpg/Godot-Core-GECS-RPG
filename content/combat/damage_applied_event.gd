## Типизированный результат успешно применённого DamageRequest.
extends RefCounted
class_name DamageAppliedEvent

## Исходный damage request с source/ability/hit context.
var request: DamageRequest

## Фактически снятое здоровье после mitigation.
var amount: float = 0.0

## C_Health.current после применения damage.
var remaining_health: float = 0.0


func _init(
	initial_request: DamageRequest,
	initial_amount: float,
	initial_remaining_health: float,
) -> void:
	request = initial_request
	amount = initial_amount
	remaining_health = initial_remaining_health
