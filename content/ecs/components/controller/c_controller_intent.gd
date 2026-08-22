## Унифицированный output любого Controller (player, AI, replay, network).
##
## Motion и Ability systems читают этот component и не зависят от конкретного
## источника управления. One-shot action flags перезаписываются controller'ом каждый frame.
extends Component
class_name C_ControllerIntent

## Нормализованное world-space направление движения на XZ plane.
var move_direction: Vector3 = Vector3.ZERO

## Желаемое world-space направление взгляда; ZERO означает использовать move_direction.
var facing_direction: Vector3 = Vector3.ZERO

var primary_pressed: bool = false
var secondary_pressed: bool = false
var interact_pressed: bool = false
