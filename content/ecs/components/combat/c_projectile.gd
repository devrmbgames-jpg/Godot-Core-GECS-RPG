## Runtime данные projectile. Node3D transform является position authority.
##
## source/ability хранятся полями, а не exact-target Relationships, потому что
## projectiles transient и высококардинальны.
extends Component
class_name C_Projectile

var velocity: Vector3 = Vector3.ZERO
var damage: float = 0.0
var remaining_lifetime: float = 0.0
var source: Entity
var ability: Entity
var definition: AbilityDefinition


## Создаёт projectile gameplay state; spatial position по-прежнему принадлежит Node3D Entity.
func _init(
	initial_velocity: Vector3 = Vector3.ZERO,
	initial_damage: float = 0.0,
	initial_lifetime: float = 0.0,
	initial_source: Entity = null,
	initial_ability: Entity = null,
	initial_definition: AbilityDefinition = null,
) -> void:
	velocity = initial_velocity
	damage = initial_damage
	remaining_lifetime = initial_lifetime
	source = initial_source
	ability = initial_ability
	definition = initial_definition
