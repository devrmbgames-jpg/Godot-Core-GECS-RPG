## Future-facing AI decision output для interaction.
##
## Behavior/utility/GOAP слой в будущем выбирает [member target] по своей ситуации.
## Generic interaction system только проверяет, что target сейчас доступен через Area3D,
## и никогда не подменяет AI-решение ближайшим случайным объектом.
extends Component
class_name C_AIInteractionGoal

var target: Entity
var request_interaction: bool = false


## Сбрасывает AI interaction decision и one-shot request после выполнения/отмены.
func clear() -> void:
	target = null
	request_interaction = false
