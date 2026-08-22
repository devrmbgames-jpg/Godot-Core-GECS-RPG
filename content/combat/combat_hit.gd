## Типизированный результат gameplay raycast.
##
## Godot Physics API возвращает Dictionary, но этот тип не выпускает строковые ключи
## за пределы CombatQuery. Все combat/interaction systems работают с полями класса.
extends RefCounted
class_name CombatHit

## Gameplay Entity, найденная подъёмом от physics collider по SceneTree.
## Может быть null, если ray попал в обычную геометрию мира.
var entity: Entity

## World-space точка столкновения.
var position: Vector3 = Vector3.ZERO

## World-space normal поверхности.
var normal: Vector3 = Vector3.ZERO


func _init(
	initial_entity: Entity = null,
	initial_position: Vector3 = Vector3.ZERO,
	initial_normal: Vector3 = Vector3.ZERO,
) -> void:
	entity = initial_entity
	position = initial_position
	normal = initial_normal


## True, если physics hit принадлежит gameplay Entity.
func has_entity() -> bool:
	return entity != null and is_instance_valid(entity)
