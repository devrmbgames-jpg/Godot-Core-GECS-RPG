## Неструктурная ссылка на item/passive/effect, выдавший runtime ability.
extends Component
class_name C_GrantedBy

var source: Entity


func _init(initial_source: Entity = null) -> void:
	source = initial_source
