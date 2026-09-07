## Типизированный результат успешно применённого DamageRequest.
extends RefCounted
class_name DamageAppliedEvent

## Исходный damage request с source/ability/hit context.
var request: DamageRequest

## Фактически снятое здоровье после mitigation.
var amount: float = 0.0

## C_Health.current после применения damage.
var remaining_health: float = 0.0

## Optional elemental calculation trace; null for legacy/custom damage observers.
var elemental_resolution: ElementalDamageResolution


## Создаёт immutable result с фактическим damage и Health после применения.
func _init(
	initial_request: DamageRequest,
	initial_amount: float,
	initial_remaining_health: float,
	initial_elemental_resolution: ElementalDamageResolution = null,
) -> void:
	request = initial_request
	amount = initial_amount
	remaining_health = initial_remaining_health
	elemental_resolution = initial_elemental_resolution
