## Переводит Controller action flags в semantic ability-slot queue.
extends System
class_name S_AbilityIntent


## Выбирает actors, для которых любой controller уже подготовил action intent и ability queue.
func query() -> QueryBuilder:
	return q.with_all([C_ControllerIntent, C_AbilityQueue]).iterate([C_ControllerIntent, C_AbilityQueue])


## Кладёт one-shot primary/secondary/skill_1 flags в FIFO semantic slots; dead actors пропускаются.
func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	var intents: Array = components[0]
	var queues: Array = components[1]
	for index in intents.size():
		if entities[index].has_component(C_Dead):
			continue
		var intent := intents[index] as C_ControllerIntent
		var queue := queues[index] as C_AbilityQueue
		if intent.primary_pressed:
			queue.push(&"primary")
		if intent.secondary_pressed:
			queue.push(&"secondary")
		if intent.skill_1_pressed:
			queue.push(&"skill_1")
