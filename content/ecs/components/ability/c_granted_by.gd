## Неструктурная ссылка на item/passive/effect, выдавший runtime ability.
extends Component
class_name C_GrantedBy

var source: Entity


## Запоминает runtime source grant-а; null означает innate/неотслеживаемый источник.
func _init(initial_source: Entity = null) -> void:
	source = initial_source
