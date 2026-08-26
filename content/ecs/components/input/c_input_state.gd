## Device-level snapshot локального ввода за текущий frame.
##
## Здесь нет world-space/camera логики: она принадлежит S_PlayerController.
extends Component
class_name C_InputState

var move_axis: Vector2 = Vector2.ZERO
var pointer_position: Vector2 = Vector2.ZERO
var primary_pressed: bool = false
var secondary_pressed: bool = false
var skill_1_pressed: bool = false
var interact_pressed: bool = false
