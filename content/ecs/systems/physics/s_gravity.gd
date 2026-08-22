extends System
class_name S_Gravity


func sub_systems() -> Array[Array]:
	return [
		[
			q.with_all(
				[C_Velocity, C_Gravity, C_IsCharacter]
			), process_kinematic_character
		]
	]


func process_kinematic_character(entities: Array[Entity], _components: Array, delta: float) -> void :
	for idx in entities.size() :
		var character := entities[idx] as Node as CharacterBody3D
		var gravity := character.get_gravity()
		character.velocity += gravity * delta
	pass
