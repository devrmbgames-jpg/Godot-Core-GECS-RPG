## Применяет project gravity к CharacterBody3D с модифицируемым C_Gravity multiplier.
## RigidBody3D использует нативную gravity Jolt и здесь не обрабатывается.
extends System
class_name S_Gravity


## Выбирает только CharacterBody actors с gravity multiplier stat.
func query() -> QueryBuilder:
	return q.with_all([C_IsCharacter, C_Gravity]).iterate([C_Gravity])


## Добавляет body.get_gravity() * multiplier * delta только пока CharacterBody не стоит на floor.
func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var gravities: Array = components[0]
	for index in entities.size():
		var body := entities[index] as Node as CharacterBody3D
		if body == null or body.is_on_floor():
			continue
		var gravity_multiplier := (gravities[index] as C_Gravity).value
		body.velocity += body.get_gravity() * gravity_multiplier * delta
