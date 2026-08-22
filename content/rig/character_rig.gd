## Абстрактный presentation adapter для импортированной модели/animation set.
## CharacterRig — scene-tree glue, не ECS Component.
extends Node3D
class_name CharacterRig

@export var model_scene: PackedScene
@export var profile: RigProfile
@export var model_root_path: NodePath
@export var animation_tree_path: NodePath
@export var animation_player_path: NodePath

var model_root: Node3D
var animation_tree: AnimationTree
var animation_player: AnimationPlayer
var _equipment_attachments: Array[RigEquipmentAttachment] = []


func _ready() -> void:
	_build_or_find_model()
	_resolve_animation_nodes()


func play_action(action: StringName, _phase: StringName = &"start") -> void:
	var mapped := profile.action_name(action) if profile != null else action
	if animation_tree != null and profile != null and profile.state_machine_playback_path != &"":
		var playback: Variant = animation_tree.get(profile.state_machine_playback_path)
		if playback != null and playback.has_method("travel"):
			playback.travel(String(mapped))
			return
	if animation_player != null and animation_player.has_animation(mapped):
		animation_player.play(mapped)


func set_locomotion(speed_ratio: float, _grounded: bool) -> void:
	if animation_tree == null or profile == null or profile.locomotion_blend_path == &"":
		return
	animation_tree.set(profile.locomotion_blend_path, clampf(speed_ratio, 0.0, 1.0))


func attach_equipment(socket: StringName, scene: PackedScene) -> void:
	detach_equipment(socket)
	if scene == null:
		return
	var anchor := get_socket(socket)
	if anchor == null:
		return
	var visual := scene.instantiate()
	anchor.add_child(visual)
	_equipment_attachments.append(RigEquipmentAttachment.new(socket, visual))


func detach_equipment(socket: StringName) -> void:
	for index in range(_equipment_attachments.size() - 1, -1, -1):
		var attachment := _equipment_attachments[index]
		if attachment == null or attachment.socket != socket:
			continue
		if attachment.visual != null and is_instance_valid(attachment.visual):
			attachment.visual.queue_free()
		_equipment_attachments.remove_at(index)


func get_socket(socket: StringName) -> Node:
	if model_root == null or profile == null:
		return null
	var path := profile.socket_path(socket)
	return model_root.get_node_or_null(path) if not path.is_empty() else null


func _build_or_find_model() -> void:
	if not model_root_path.is_empty():
		model_root = get_node_or_null(model_root_path) as Node3D
	if model_root == null and model_scene != null:
		model_root = model_scene.instantiate() as Node3D
		if model_root != null:
			add_child(model_root)
	if model_root == null:
		model_root = self


func _resolve_animation_nodes() -> void:
	if not animation_tree_path.is_empty():
		animation_tree = get_node_or_null(animation_tree_path) as AnimationTree
	if not animation_player_path.is_empty():
		animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	if animation_tree == null:
		animation_tree = _find_animation_tree(model_root)
	if animation_player == null:
		animation_player = _find_animation_player(model_root)


func _find_animation_tree(root: Node) -> AnimationTree:
	if root == null:
		return null
	for child in root.get_children():
		var candidate := child as AnimationTree
		if candidate != null:
			return candidate
		var nested := _find_animation_tree(child)
		if nested != null:
			return nested
	return null


func _find_animation_player(root: Node) -> AnimationPlayer:
	if root == null:
		return null
	for child in root.get_children():
		var candidate := child as AnimationPlayer
		if candidate != null:
			return candidate
		var nested := _find_animation_player(child)
		if nested != null:
			return nested
	return null
