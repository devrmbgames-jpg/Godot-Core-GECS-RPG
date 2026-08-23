## Маленькая persistent FIFO semantic ability-slot requests на actor.
##
## Это дешевле, чем создавать transient Cast/Request Entity на каждый input press.
extends Component
class_name C_AbilityQueue

var slots: Array[StringName] = []
@export var max_size: int = 4


func push(slot: StringName) -> void:
	if slot == &"" or slots.size() >= max_size:
		return
	slots.push_back(slot)


func pop() -> StringName:
	return slots.pop_front() if not slots.is_empty() else &""
