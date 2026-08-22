## Stateless API для добавления gameplay knockback/external velocity персонажу.
extends RefCounted
class_name MotionImpulse


## Добавляет world-space velocity delta к external motion CharacterBody Entity.
## Vertical component применяется непосредственно к CharacterBody velocity, потому
## что C_ExternalMotion хранит только отдельную horizontal contribution.
static func add_velocity(entity: Entity, velocity_delta: Vector3) -> void:
	if entity == null:
		return
	var external := entity.get_component(C_ExternalMotion) as C_ExternalMotion
	var body := entity as Node as CharacterBody3D
	if external != null:
		external.horizontal_velocity += Vector3(velocity_delta.x, 0.0, velocity_delta.z)
		external.horizontal_velocity = external.horizontal_velocity.limit_length(external.max_horizontal_speed)
	if body != null:
		body.velocity.y += velocity_delta.y
