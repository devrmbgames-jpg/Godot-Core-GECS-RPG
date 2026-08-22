extends System
class_name S_KinematicCharacter


func query() -> QueryBuilder:
	return q.with_all([C_IsCharacter])


func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
	for idx in entities.size() :
		var entity := entities[idx] as Node as CharacterBody3D
		entity.move_and_slide()
