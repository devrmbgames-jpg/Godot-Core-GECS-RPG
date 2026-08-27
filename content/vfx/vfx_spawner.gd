## Stateless scene-tree helper for independent world-space one-shot VFX.
##
## Gameplay chooses the PackedScene through design/presentation data; this helper only
## instantiates and places it. The VFX scene remains responsible for its own cleanup.
extends RefCounted
class_name VFXSpawner


## Instantiates a Node3D under the current scene and places it at world_position.
## Returns null for missing/invalid scenes or when no safe scene-tree parent exists.
static func spawn_world(scene: PackedScene, world_position: Vector3, context: Node) -> Node3D:
	if scene == null or context == null:
		return null
	var instance := scene.instantiate() as Node3D
	if instance == null:
		return null
	var parent: Node = context.get_tree().current_scene if context.is_inside_tree() else null
	if parent == null:
		parent = context.get_parent()
	if parent == null:
		instance.free()
		return null
	parent.add_child(instance)
	instance.global_position = world_position
	return instance
