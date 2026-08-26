## Минимальный AI-controller source.
##
## Steering/behavior systems записывают desired values сюда, а S_AIController
## переводит их в общий C_ControllerIntent. Action flags являются one-shot requests.
extends Component
class_name C_AIController

@export var enabled: bool = true

var desired_move_direction: Vector3 = Vector3.ZERO
var desired_facing_direction: Vector3 = Vector3.ZERO
var wants_primary: bool = false
var wants_secondary: bool = false
var wants_skill_1: bool = false
var wants_interact: bool = false
