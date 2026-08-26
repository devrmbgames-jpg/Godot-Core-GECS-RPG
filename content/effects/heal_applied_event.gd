## Типизированный результат успешно применённого HealRequest.
extends RefCounted
class_name HealAppliedEvent

## Исходный heal request с source/ability context.
var request: HealRequest

## Фактически восстановленное здоровье после clamp к MaxHealth.
var amount: float = 0.0

## C_Health.current после лечения.
var current_health: float = 0.0


## Создаёт immutable result с фактическим heal amount и Health после clamp.
func _init(
	initial_request: HealRequest,
	initial_amount: float,
	initial_current_health: float,
) -> void:
	request = initial_request
	amount = initial_amount
	current_health = initial_current_health
