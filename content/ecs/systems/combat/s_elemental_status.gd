## Advances buildup decay and active status duration on elemental subjects.
extends System
class_name S_ElementalStatus


## Iterates the persistent status component without structural churn.
func query() -> QueryBuilder:
	return q.with_all([C_ElementalState]).iterate([C_ElementalState])


## Advances clocks and emits typed transitions for UI/presentation observers.
func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var states: Array = components[0]
	for index in entities.size():
		var state := states[index] as C_ElementalState
		for transition in state.advance(delta):
			ECS.world.emit_event(
				ElementalService.EVENT_STATUS_RESOLVED,
				entities[index],
				ElementalStatusResolvedEvent.new(null, transition),
			)
