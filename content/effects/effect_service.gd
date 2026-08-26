## Stateless API применения effects через targeted GECS events.
extends RefCounted
class_name EffectService

const EVENT_APPLY: StringName = &"effect_apply_requested"


## Запрашивает применение одной immutable EffectDefinition к target с optional source context.
static func request(
	target: Entity,
	definition: EffectDefinition,
	source: Entity = null,
	ability: Entity = null,
) -> void:
	if ECS.world == null or target == null or definition == null:
		return
	ECS.world.emit_event(EVENT_APPLY, target, EffectApplyRequest.new(definition, source, ability))


## Публикует независимый apply request для каждой definition в порядке массива.
static func request_all(
	target: Entity,
	definitions: Array[EffectDefinition],
	source: Entity = null,
	ability: Entity = null,
) -> void:
	for definition in definitions:
		request(target, definition, source, ability)
