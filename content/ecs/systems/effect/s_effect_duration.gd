## Завершает status-effect instances после истечения duration.
extends System
class_name S_EffectDuration


func query() -> QueryBuilder:
	return q.with_all([C_Effect, C_Duration]).iterate([C_Duration])


func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var durations: Array = components[0]
	for index in entities.size():
		var duration := durations[index] as C_Duration
		duration.remaining -= delta
		if duration.remaining <= 0.0:
			var effect := entities[index]
			cmd.add_custom(func(): EffectRuntime.remove(effect))
