## Маленькая persistent FIFO semantic ability-slot requests на actor.
##
## Это дешевле, чем создавать transient Cast/Request Entity на каждый input press.
extends Component
class_name C_AbilityQueue

var slots: Array[StringName] = []
@export var max_size: int = 4


## Добавляет semantic slot в хвост очереди; пустой slot и overflow безопасно игнорируются.
func push(slot: StringName) -> void:
	if slot == &"" or slots.size() >= max_size:
		return
	slots.push_back(slot)


## Извлекает первый queued slot или возвращает пустой StringName, если очередь пуста.
func pop() -> StringName:
	return slots.pop_front() if not slots.is_empty() else &""
