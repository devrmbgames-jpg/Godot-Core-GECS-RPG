## Scene-tree presentation adapter для optional C_InterractDrawing.
extends RefCounted
class_name InteractionDrawingPresenter


static func set_highlight(target: Entity, enabled: bool) -> void:
	if target == null or not is_instance_valid(target):
		return
	var drawing: C_InterractDrawing = target.get_component(C_InterractDrawing) as C_InterractDrawing
	if drawing == null or drawing.highlighted == enabled:
		return
	var target_node: Node = target as Node
	var mesh: MeshInstance3D = target_node.get_node_or_null(drawing.mesh_path) as MeshInstance3D if target_node != null else null
	if mesh == null:
		return
	if enabled:
		drawing.original_overlay = mesh.material_overlay
		if drawing.highlight_material == null:
			var material := StandardMaterial3D.new()
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			material.albedo_color = drawing.highlight_color
			material.emission_enabled = true
			material.emission = Color(drawing.highlight_color.r, drawing.highlight_color.g, drawing.highlight_color.b, 1.0)
			material.emission_energy_multiplier = drawing.emission_energy
			drawing.highlight_material = material
		mesh.material_overlay = drawing.highlight_material
	else:
		mesh.material_overlay = drawing.original_overlay
		drawing.original_overlay = null
	drawing.highlighted = enabled
