## Абстрактный presentation adapter для импортированной модели/animation set.
##
## CharacterRig является scene-tree glue, не ECS Component. Gameplay обращается к
## нему только через presentation observer и semantic ids.
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
var _equipment_nodes: Dictionary = {}


func _ready() -> void:
	_build_or_find_model()
	_resolve_animation_nodes()


## Запускает semantic gameplay action на текущем animation backend.
func play_action(action: StringName, _phase: StringName = &"start") -> void:
	var mapped := profile.action_name(action) if profile != null else action
	if animation_tree != null and profile != null and profile.state_machine_playback_path != &"":
		var playback: Variant = animation_tree.get(String(profile.state_machine_playback_path))
		if playback != null and playback.has_method("travel"):
			playback.travel(String(mapped))
			return
	if animation_player != null and animation_player.has_animation(mapped):
		animation_player.play(mapped)


## Обновляет normalized locomotion blend, если profile указал путь property.
func set_locomotion(speed_ratio: float, _grounded: bool) -> void:
	if animation_tree == null or profile == null or profile.locomotion_blend_path == &"":
		return
	animation_tree.set(String(profile.locomotion_blend_path), clampf(speed_ratio, 0.0, 1.0))


## Прикрепляет visual scene к semantic socket, заменяя прошлый visual этого socket.
func attach_equipment(socket: StringName, scene: PackedScene) -> void:
	detach_equipment(socket)
	if scene == null:
		return
	var anchor := get_socket(socket)
	if anchor == null:
		return
	var visual := scene.instantiate()
	anchor.add_child(visual)
	_equipment_nodes[socket] = visual


## Удаляет visual equipment с semantic socket.
func detach_equipment(socket: StringName) -> void:
	var visual: Node = _equipment_nodes.get(socket)
	if visual != null and is_instance_valid(visual):
		visual.queue_free()
	_equipment_nodes.erase(socket)


## Возвращает Node socket из RigProfile относительно model root.
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
		animation_tree = _find_descendant(model_root, AnimationTree) as AnimationTree
	if animation_player == null:
		animation_player = _find_descendant(model_root, AnimationPlayer) as AnimationPlayer


func _find_descendant(root: Node, type_script: Variant) -> Node:
	if root == null:
		return null
	for child in root.get_children():
		if is_instance_of(child, type_script):
			return child
		var nested := _find_descendant(child, type_script)
		if nested != null:
			return nested
	return null
