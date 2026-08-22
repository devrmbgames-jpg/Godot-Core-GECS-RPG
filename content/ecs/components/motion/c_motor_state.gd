## Runtime state управляемой части locomotion motor.
##
## [member controlled_velocity] не дублирует CharacterBody3D.velocity: это только
## velocity, созданная controller input, без gravity и external impulses.
extends Component
class_name C_MotorState

var controlled_velocity: Vector3 = Vector3.ZERO
