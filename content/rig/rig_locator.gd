## Cached scene-tree lookup CharacterRig. Cache хранится как metadata самого actor Node.
extends RefCounted
class_name RigLocator

const META_KEY: StringName = &"arpg_character_rig"


## Возвращает CharacterRig actor, используя metadata cache после первого recursive lookup.
static func find(actor: Entity) -> CharacterRig:
	if actor == null:
		return null
	var cached: Variant = actor.get_meta(META_KEY, null)
	if cached is CharacterRig and is_instance_valid(cached):
		return cached as CharacterRig
	var rig := _find_recursive(actor)
	if rig != null:
		actor.set_meta(META_KEY, rig)
	return rig


## Ищет первый CharacterRig depth-first внутри subtree node.
static func _find_recursive(node: Node) -> CharacterRig:
	for child in node.get_children():
		if child is CharacterRig:
			return child as CharacterRig
		var nested := _find_recursive(child)
		if nested != null:
			return nested
	return null
