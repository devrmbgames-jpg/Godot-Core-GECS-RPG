## Типизированный результат gameplay raycast.
##
## Godot Physics API возвращает Dictionary, но этот тип не выпускает строковые ключи
## за пределы CombatQuery. Все combat/interaction systems работают с полями класса.
extends RefCounted
class_name CombatHit

## Gameplay Entity, найденная подъёмом от physics collider по SceneTree.
var entity: Entity

## World-space точка столкновения.
var position: Vector3 = Vector3.ZERO

## World-space normal поверхности.
var normal: Vector3 = Vector3.ZERO

## Исходный physics collider, если он является CollisionObject3D.
var collider: CollisionObject3D


func _init(
	initial_entity: Entity = null,
	initial_position: Vector3 = Vector3.ZERO,
	initial_normal: Vector3 = Vector3.ZERO,
	initial_collider: CollisionObject3D = null,
) -> void:
	entity = initial_entity
	position = initial_position
	normal = initial_normal
	collider = initial_collider


## True, если raycast разрешился в gameplay Entity.
func is_valid() -> bool:
	return entity != null and is_instance_valid(entity)
