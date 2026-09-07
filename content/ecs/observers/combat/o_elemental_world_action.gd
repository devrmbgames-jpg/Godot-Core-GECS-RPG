## Optional adapter that maps semantic reaction actions to world scenes and EffectDefinitions.
extends Observer
class_name O_ElementalWorldAction

@export var bindings: Array[ElementalWorldActionBinding] = []
@export var spawn_parent_path: NodePath


## Listens for typed world actions on any elemental subject.
func query() -> QueryBuilder:
	return q.on_event(ElementalService.EVENT_WORLD_ACTION_REQUESTED)


## Spawns configured scenes or applies configured effects; surface state was already changed by core.
func each(_event: Variant, target: Entity, payload: Variant = null) -> void:
	var action := payload as ElementalWorldActionEvent
	if target == null or action == null:
		return
	var binding := _find_binding(action.semantic_id)
	if binding == null:
		return
	match action.kind:
		ElementalReactionActionDefinition.Kind.SPAWN_ENTITY:
			_spawn(binding.spawn_scene, action.hit_position)
		ElementalReactionActionDefinition.Kind.EMIT_EFFECT:
			if binding.effect_definition != null:
				EffectService.request(target, EffectApplyRequest.new(binding.effect_definition, action.source, action.ability))


## Finds a world-owned binding without exposing a Dictionary contract.
func _find_binding(semantic_id: StringName) -> ElementalWorldActionBinding:
	for binding in bindings:
		if binding != null and binding.semantic_id == semantic_id:
			return binding
	return null


## Instantiates a configured scene under the explicit parent or current scene fallback.
func _spawn(scene: PackedScene, position: Vector3) -> void:
	if scene == null:
		return
	var parent := get_node_or_null(spawn_parent_path)
	if parent == null:
		parent = get_tree().current_scene
	if parent == null:
		return
	var instance := scene.instantiate()
	parent.add_child(instance)
	var spatial := instance as Node3D
	if spatial != null:
		spatial.global_position = position
