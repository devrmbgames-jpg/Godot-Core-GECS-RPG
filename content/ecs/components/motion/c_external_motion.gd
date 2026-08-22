## Внешняя horizontal velocity, не принадлежащая locomotion input.
##
## Используется для knockback, moving contacts и приближённого влияния RigidBody3D
## на CharacterBody3D. Значение постепенно затухает, а motor не уничтожает его мгновенно.
extends Component
class_name C_ExternalMotion

var horizontal_velocity: Vector3 = Vector3.ZERO

## Скорость затухания external horizontal velocity, м/с².
@export var damping: float = 8.0

## Виртуальная масса CharacterBody для передачи contact impulse.
@export var virtual_mass: float = 80.0

## Доля relative contact velocity, передаваемая CharacterBody.
@export_range(0.0, 1.0, 0.01) var rigid_contact_transfer: float = 0.35

## Ограничение external horizontal speed для защиты от нестабильных contacts.
@export var max_horizontal_speed: float = 20.0
