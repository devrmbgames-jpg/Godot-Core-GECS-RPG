## Минимальный AI-controller source.
##
## Steering/behavior systems записывают desired values сюда, а S_AIController
## переводит их в общий C_ControllerIntent. Это оставляет Motion одинаковым для AI и Player.
extends Component
class_name C_AIController

var desired_move_direction: Vector3 = Vector3.ZERO
var desired_facing_direction: Vector3 = Vector3.ZERO
var wants_primary: bool = false
var wants_secondary: bool = false
var wants_interact: bool = false
