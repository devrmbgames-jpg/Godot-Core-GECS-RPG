## Ограничивает current health новым C_MaxHealth.value после stat rebuild.
extends Observer
class_name O_HealthBounds


func query() -> QueryBuilder:
	return q.with_all([C_Health, C_MaxHealth]).on_changed([&"value"])


func each(_event: Variant, entity: Entity, _payload: Variant = null) -> void:
	var health := entity.get_component(C_Health) as C_Health
	var maximum := entity.get_component(C_MaxHealth) as C_MaxHealth
	if health != null and maximum != null:
		health.current = clampf(health.current, 0.0, maxf(maximum.value, 0.0))
