## Advances elemental gauge duration/decay and synchronizes gauge-owned Effect Entity lifecycles.
extends System
class_name S_ElementalStatus


## Iterates every Entity with persistent elemental state; no structural component churn is required.
func query() -> QueryBuilder:
	return q.with_all([C_ElementalState]).iterate([C_ElementalState])


## Advances gauges once per frame and dispatches only when strength/activation/lifetime reaches a state change.
func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var states: Array = components[0]
	var catalog := ElementalService.catalog()
	for index in entities.size():
		var entity := entities[index]
		var state := states[index] as C_ElementalState
		if state == null:
			continue
		var result := ElementalResolver.tick(state, catalog, delta)
		if result.changed:
			ElementalService.dispatch(entity, result)
