## Выполняет CharacterBody3D.move_and_slide() и преобразует контакты с RigidBody3D
## в C_ExternalMotion, чтобы kinematic actor мог получать приближённый внешний push.
extends System
class_name S_KinematicCharacter


## Выбирает CharacterBody-tagged Entity; конкретный Node type проверяется во время process.
func query() -> QueryBuilder:
	return q.with_all([C_IsCharacter])


## Выполняет move_and_slide(), затем переводит slide contacts с RigidBody в gameplay external impulse.
func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
	for entity in entities:
		var body := entity as Node as CharacterBody3D
		if body == null:
			continue
		body.move_and_slide()
		_apply_rigid_contacts(entity, body)


## Оценивает относительную contact speed/mass ratio и добавляет transferred velocity через MotionImpulse.
func _apply_rigid_contacts(entity: Entity, body: CharacterBody3D) -> void:
	var external := entity.get_component(C_ExternalMotion) as C_ExternalMotion
	if external == null:
		return
	for collision_index in body.get_slide_collision_count():
		var collision := body.get_slide_collision(collision_index)
		var rigid := collision.get_collider() as RigidBody3D
		if rigid == null:
			continue
		var normal := collision.get_normal()
		var relative := rigid.linear_velocity - body.get_real_velocity()
		var contact_speed := absf(relative.dot(normal))
		if contact_speed <= 0.05:
			continue
		var mass_ratio := rigid.mass / maxf(rigid.mass + external.virtual_mass, 0.001)
		var transferred := normal * contact_speed * external.rigid_contact_transfer * mass_ratio
		MotionImpulse.add_velocity(entity, transferred)
