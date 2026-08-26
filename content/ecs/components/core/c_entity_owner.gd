## Неструктурная ссылка на владельца runtime Entity.
##
## Используется для высококардинальных owner references (Ability/Effect/Projectile),
## которые не должны создавать unique relationship pair archetypes в GECS v8.
extends Component
class_name C_EntityOwner

var owner: Entity


## Создаёт non-relationship owner reference; owner может быть null для unowned runtime Entity.
func _init(initial_owner: Entity = null) -> void:
	owner = initial_owner
