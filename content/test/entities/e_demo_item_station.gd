## Размещаемая в .tscn primitive-station, выдающая новый runtime Item Entity.
## Station остаётся в мире как reusable design-time prototype, сам Item создаёт ItemFactory.
@tool
extends Entity
class_name E_DemoItemStation

enum ItemKind { SWORD, BOW, STAFF }

@export var item_kind: ItemKind = ItemKind.SWORD:
	set(value):
		item_kind = value
		if is_inside_tree():
			_refresh_visual()


func define_components() -> Array:
	var interactable := C_Interactable.new()
	interactable.prompt = "Equip %s" % _display_name()
	interactable.max_distance = 3.0
	return [C_DemoItemStation.new(_item_id()), interactable]


func _ready() -> void:
	_refresh_visual()


func _item_id() -> StringName:
	match item_kind:
		ItemKind.SWORD: return &"sword"
		ItemKind.BOW: return &"bow"
		ItemKind.STAFF: return &"staff"
	return &"sword"


func _display_name() -> String:
	match item_kind:
		ItemKind.SWORD: return "Sword"
		ItemKind.BOW: return "Bow"
		ItemKind.STAFF: return "Magic Staff"
	return "Item"


func _item_color() -> Color:
	match item_kind:
		ItemKind.SWORD: return Color(0.8, 0.82, 0.9)
		ItemKind.BOW: return Color(0.55, 0.32, 0.12)
		ItemKind.STAFF: return Color(0.25, 0.5, 1.0)
	return Color.WHITE


func _refresh_visual() -> void:
	var label := get_node_or_null("Label3D") as Label3D
	if label != null:
		label.text = "E: Equip %s" % _display_name()
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh != null:
		var material := StandardMaterial3D.new()
		material.albedo_color = _item_color()
		mesh.material_override = material
