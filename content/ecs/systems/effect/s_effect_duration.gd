## Завершает status-effect instances после истечения duration.
extends System
class_name S_EffectDuration


## Выбирает runtime Effect Entity, имеющие duration clock.
func query() -> QueryBuilder:
	return q.with_all([C_Effect, C_Duration]).iterate([C_Duration])


## Уменьшает remaining и deferred-call EffectRuntime.remove после истечения lifetime.
func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var durations: Array = components[0]
	for index in entities.size():
		var duration := durations[index] as C_Duration
		duration.remaining -= delta
		if duration.remaining <= 0.0:
			cmd.add_custom(EffectRuntime.remove.bind(entities[index]))
