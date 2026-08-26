## Поддерживает combat state по nearby-enemy Area3D и linger timer.
extends System
class_name S_CombatState


## Выбирает живых actors с C_CombatState и кеширует сам state для hot iteration.
func query() -> QueryBuilder:
	return q.with_all([C_CombatState]).with_none([C_Dead]).iterate([C_CombatState])


## Обновляет nearby enemy count через CombatAwareness; enemies refresh linger, иначе timer истекает.
func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var states: Array = components[0]
	for index in entities.size():
		var actor: Entity = entities[index]
		var state: C_CombatState = states[index] as C_CombatState
		state.nearby_enemy_count = CombatAwareness.count_nearby_enemies(actor, state)
		if state.nearby_enemy_count > 0:
			state.refresh()
			continue
		if not state.active:
			continue
		state.remaining = maxf(0.0, state.remaining - delta)
		if state.remaining <= 0.0:
			state.active = false
