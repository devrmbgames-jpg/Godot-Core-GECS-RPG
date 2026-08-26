## Для local Player Controller выбирает единственный ближайший валидный Area3D overlap.
extends System
class_name S_PlayerInteractionSelection


func query() -> QueryBuilder:
	return q.with_all([C_PlayerController, C_InteractionSensor, C_InteractionRange]).with_none([C_Dead]).iterate([C_InteractionSensor])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var sensors: Array = components[0]
	for index in entities.size():
		var actor: Entity = entities[index]
		var sensor: C_InteractionSensor = sensors[index] as C_InteractionSensor
		var nearest: Entity = InteractionTargeting.nearest_valid(actor, sensor)
		InteractionSelectionService.set_target(actor, nearest)
