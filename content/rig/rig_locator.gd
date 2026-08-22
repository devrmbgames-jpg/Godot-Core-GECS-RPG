## Stateless поиск CharacterRig в actor subtree. Вызывается только presentation events/systems.
extends RefCounted
class_name RigLocator


static func find(actor: Entity) -> CharacterRig:
	return _find_recursive(actor) if actor != null else null


static func _find_recursive(node: Node) -> CharacterRig:
	for child in node.get_children():
		if child is CharacterRig:
			return child as CharacterRig
		var nested := _find_recursive(child)
		if nested != null:
			return nested
	return null
