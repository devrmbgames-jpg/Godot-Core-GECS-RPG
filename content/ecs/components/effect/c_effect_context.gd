## Runtime context effect. Высококардинальные refs хранятся полями, не pair targets.
extends Component
class_name C_EffectContext

var target: Entity
var source: Entity
var ability: Entity
var stacks: int = 1


## Создаёт high-cardinality runtime context target/source/ability без relationship pair targets.
func _init(
	initial_target: Entity = null,
	initial_source: Entity = null,
	initial_ability: Entity = null,
) -> void:
	target = initial_target
	source = initial_source
	ability = initial_ability
