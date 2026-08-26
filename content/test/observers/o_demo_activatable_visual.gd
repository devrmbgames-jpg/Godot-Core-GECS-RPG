## Demo-only presentation: делает состояние generic C_Activatable видимым на primitive cube.
extends Observer
class_name O_DemoActivatableVisual


## Слушает activation state changes только на demo-compatible targets с C_Activatable.
func query() -> QueryBuilder:
	return q.with_all([C_Activatable]).on_event(InteractionService.EVENT_STATE_CHANGED)


## Меняет scale/material primitive cube согласно typed active state; gameplay state не вычисляется здесь.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var state_changed := payload as InteractionStateChangedEvent
	if state_changed == null:
		return
	var mesh := target.get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh == null:
		return
	mesh.scale = Vector3(1.0, 2.0 if state_changed.active else 1.0, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.15, 0.9, 0.25) if state_changed.active else Color(0.9, 0.55, 0.1)
	mesh.material_override = material
