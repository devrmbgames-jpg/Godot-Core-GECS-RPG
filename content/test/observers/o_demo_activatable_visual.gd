## Demo-only presentation: делает состояние generic C_Activatable видимым на primitive cube.
extends Observer
class_name O_DemoActivatableVisual


func query() -> QueryBuilder:
	return q.with_all([C_Activatable]).on_event(InteractionService.EVENT_STATE_CHANGED)


func each(_event: Variant, target: Entity, payload: Variant) -> void:
	var active: bool = payload.get("active", false) if payload is Dictionary else false
	var mesh := target.get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh == null:
		return
	mesh.scale = Vector3(1.0, 2.0 if active else 1.0, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.15, 0.9, 0.25) if active else Color(0.9, 0.55, 0.1)
	mesh.material_override = material
