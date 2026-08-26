## Immutable payload запроса на применение EffectDefinition.
extends RefCounted
class_name EffectApplyRequest

var definition: EffectDefinition
var source: Entity
var ability: Entity


## Создаёт immutable apply context с optional source actor и originating ability.
func _init(
	initial_definition: EffectDefinition = null,
	initial_source: Entity = null,
	initial_ability: Entity = null,
) -> void:
	definition = initial_definition
	source = initial_source
	ability = initial_ability
