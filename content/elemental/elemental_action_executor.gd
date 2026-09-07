## Executes closed core reaction actions and forwards semantic world actions to adapters.
extends RefCounted
class_name ElementalActionExecutor


## Executes one queued action while preserving its shared reaction context.
static func execute(
	target: Entity,
	queued: ElementalQueuedAction,
	catalog: ElementalCatalog,
	context: ElementalResolutionContext,
) -> void:
	if target == null or queued == null or queued.definition == null:
		return
	var action := queued.definition
	var amount := action.resolve_amount(queued.reaction_power)
	match action.kind:
		ElementalReactionActionDefinition.Kind.MODIFY_STATUS:
			_modify_status(target, action.status_id, amount)
		ElementalReactionActionDefinition.Kind.APPLY_STATUS:
			ElementalResolver.apply_status(target, ElementalStatusRequest.new(
				queued.source, queued.ability, action.status_id, maxf(amount, 0.0), context,
				queued.hit_position, queued.direction,
			), catalog)
		ElementalReactionActionDefinition.Kind.REMOVE_STATUS:
			_remove_status(target, action.status_id)
		ElementalReactionActionDefinition.Kind.DEAL_DAMAGE:
			_damage(target, queued, action.damage_type, amount, context)
		ElementalReactionActionDefinition.Kind.ADD_MATERIAL:
			_add_material(target, action.semantic_id)
		ElementalReactionActionDefinition.Kind.REMOVE_MATERIAL:
			_remove_material(target, action.semantic_id)
		ElementalReactionActionDefinition.Kind.TRANSFORM_SURFACE:
			_transform_surface(target, queued, action.semantic_id)
		_:
			_publish_world_action(target, queued, action, amount)


## Applies signed status buildup without retriggering reactions for consumption-only changes.
static func _modify_status(target: Entity, status_id: StringName, amount: float) -> void:
	var state := target.get_component(C_ElementalState) as C_ElementalState
	if state == null:
		return
	var status := state.get_status(status_id)
	if status != null:
		var transition := status.apply_delta(amount)
		_emit_transition(target, transition)


## Clears status buildup and activity.
static func _remove_status(target: Entity, status_id: StringName) -> void:
	var state := target.get_component(C_ElementalState) as C_ElementalState
	if state != null:
		var transition := state.remove_status(status_id)
		_emit_transition(target, transition)


## Sends nested reaction damage through the same typed DamageService pipeline with zero automatic buildup.
static func _damage(
	target: Entity,
	queued: ElementalQueuedAction,
	damage_type: StringName,
	amount: float,
	context: ElementalResolutionContext,
) -> void:
	if amount <= 0.0:
		return
	DamageService.request(target, DamageRequest.new(
		queued.source, queued.ability, amount, queued.hit_position, queued.direction,
		DamageRequest.Kind.DIRECT, damage_type, 0.0, context,
	))


## Adds one material tag through the component API.
static func _add_material(target: Entity, material_id: StringName) -> void:
	var materials := target.get_component(C_ReactiveMaterials) as C_ReactiveMaterials
	if materials != null:
		materials.add_material(material_id)


## Removes one material tag through the component API.
static func _remove_material(target: Entity, material_id: StringName) -> void:
	var materials := target.get_component(C_ReactiveMaterials) as C_ReactiveMaterials
	if materials != null:
		materials.remove_material(material_id)


## Replaces surface material tags and publishes the semantic transform for scene/cell adapters.
static func _transform_surface(target: Entity, queued: ElementalQueuedAction, surface_id: StringName) -> void:
	var materials := target.get_component(C_ReactiveMaterials) as C_ReactiveMaterials
	if materials != null:
		materials.material_ids.clear()
		materials.add_material(surface_id)
	var placeholder_action := ElementalReactionActionDefinition.new()
	placeholder_action.kind = ElementalReactionActionDefinition.Kind.TRANSFORM_SURFACE
	placeholder_action.semantic_id = surface_id
	_publish_world_action(target, queued, placeholder_action, 0.0)


## Publishes spawn/surface/effect intent without taking scene-tree ownership in core.
static func _publish_world_action(
	target: Entity,
	queued: ElementalQueuedAction,
	action: ElementalReactionActionDefinition,
	amount: float,
) -> void:
	ElementalService.publish_world_action(target, ElementalWorldActionEvent.new(
		target, queued.source, queued.ability, action.kind, action.semantic_id, amount,
		queued.hit_position, queued.direction,
	))


## Publishes reaction-driven status changes for UI/presentation observers.
static func _emit_transition(target: Entity, transition: ElementalStatusTransition) -> void:
	if ECS.world != null and transition != null:
		ECS.world.emit_event(
			ElementalService.EVENT_STATUS_RESOLVED,
			target,
			ElementalStatusResolvedEvent.new(null, transition),
		)
