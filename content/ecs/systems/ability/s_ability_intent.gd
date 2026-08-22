## Переводит Controller action flags в semantic ability-slot queue.
extends System
class_name S_AbilityIntent


func query() -> QueryBuilder:
	return q.with_all([C_ControllerIntent, C_AbilityQueue]).iterate([C_ControllerIntent, C_AbilityQueue])


func process(_entities: Array[Entity], components: Array, _delta: float) -> void:
	var intents: Array = components[0]
	var queues: Array = components[1]
	for index in intents.size():
		var intent := intents[index] as C_ControllerIntent
		var queue := queues[index] as C_AbilityQueue
		if intent.primary_pressed:
			queue.push(&"primary")
		if intent.secondary_pressed:
			queue.push(&"secondary")
		if intent.skill_1_pressed:
			queue.push(&"skill_1")
