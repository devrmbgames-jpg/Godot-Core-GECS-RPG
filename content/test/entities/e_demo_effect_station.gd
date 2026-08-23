## Размещаемая в .tscn primitive-station для ручной проверки Effect system.
@tool
extends Entity
class_name E_DemoEffectStation

enum EffectKind { POISON, BURNING, HEAL, REGENERATION, HASTE, SLOW }

@export var effect_kind: EffectKind = EffectKind.POISON:
	set(value):
		effect_kind = value
		if is_inside_tree():
			_refresh_visual()


func define_components() -> Array:
	var interactable := C_Interactable.new()
	interactable.prompt = "Apply %s" % _display_name()
	interactable.max_distance = 3.0
	return [interactable, C_DemoEffectStation.new(_effect_id())]


func _ready() -> void:
	_refresh_visual()


func _effect_id() -> StringName:
	match effect_kind:
		EffectKind.POISON: return &"poison"
		EffectKind.BURNING: return &"burning"
		EffectKind.HEAL: return &"heal"
		EffectKind.REGENERATION: return &"regeneration"
		EffectKind.HASTE: return &"haste"
		EffectKind.SLOW: return &"slow"
	return &"poison"


func _display_name() -> String:
	return String(_effect_id()).capitalize()


func _effect_color() -> Color:
	match effect_kind:
		EffectKind.POISON: return Color(0.55, 0.2, 0.8)
		EffectKind.BURNING: return Color(1.0, 0.25, 0.05)
		EffectKind.HEAL: return Color(0.1, 0.9, 0.25)
		EffectKind.REGENERATION: return Color(0.2, 0.75, 0.45)
		EffectKind.HASTE: return Color(0.15, 0.65, 1.0)
		EffectKind.SLOW: return Color(0.2, 0.4, 0.85)
	return Color.WHITE


func _refresh_visual() -> void:
	var label := get_node_or_null("Label3D") as Label3D
	if label != null:
		label.text = "E: %s" % _display_name()
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh != null:
		var material := StandardMaterial3D.new()
		material.albedo_color = _effect_color()
		material.emission_enabled = true
		material.emission = _effect_color() * 0.35
		mesh.material_override = material
