## Small event boundary for elemental gameplay. Cached catalogs are design data, not runtime authority.
## Gauges live in C_ElementalState; effect and spatial lifecycles belong to their existing systems.
extends RefCounted
class_name ElementalService

const EVENT_STATUS_REQUESTED: StringName = &"elemental_status_requested"
const EVENT_ENVIRONMENT_IMPACT: StringName = &"elemental_environment_impact"
const EVENT_RESOLVED: StringName = &"elemental_resolved"

static var _catalog: ElementalCatalog
static var _environment_catalog: ElementalEnvironmentCatalog


## Returns the shared prototype definition catalog, building it only once.
static func catalog() -> ElementalCatalog:
	if _catalog == null:
		_catalog = ElementalPrototypeCatalog.build()
	return _catalog


## Replaces design data for a world or tests after validation; does not migrate existing gauges.
static func configure_catalog(value: ElementalCatalog) -> bool:
	if value == null or not value.validate().is_empty():
		return false
	_catalog = value
	return true


## Returns the shared material/spawn profiles without owning any runtime world entities.
static func environment_catalog() -> ElementalEnvironmentCatalog:
	if _environment_catalog == null:
		_environment_catalog = ElementalPrototypeEnvironment.build()
	return _environment_catalog


## Replaces environment design data after validation against the active elemental catalog.
static func configure_environment_catalog(value: ElementalEnvironmentCatalog) -> bool:
	if value == null or not value.validate(catalog()).is_empty():
		return false
	_environment_catalog = value
	return true


## Publishes a typed direct-status request. The observer enforces team policy and status immunity.
static func request_status(target: Entity, request: ElementalStatusRequest) -> void:
	if ECS.world == null or target == null or request == null:
		return
	ECS.world.emit_event(EVENT_STATUS_REQUESTED, target, request)


## Publishes a direct status addition without constructing a damage request.
static func apply_status(target: Entity, status_id: StringName, amount: float, source: Entity = null, ability: Entity = null, allow_friendly: bool = false) -> void:
	var request := ElementalStatusRequest.new(status_id, amount, source, ability)
	request.allow_friendly = allow_friendly
	request_status(target, request)


## Publishes a direct status removal or clearing operation.
static func remove_status(target: Entity, status_id: StringName, amount: float = 0.0, clear: bool = true) -> void:
	var operation := ElementalStatusRequest.Operation.CLEAR if clear else ElementalStatusRequest.Operation.REMOVE
	request_status(target, ElementalStatusRequest.new(status_id, amount, null, null, operation))


## Publishes the typed resolution and executes its external actions in their resolved order.
## An empty action list is valid; status changes still synchronize owned effects.
static func dispatch(target: Entity, result: ElementalResolution) -> void:
	if ECS.world == null or target == null or not is_instance_valid(target) or result == null:
		return
	if result.changed:
		sync_effects(target)
	ECS.world.emit_event(EVENT_RESOLVED, target, result)
	for execution in result.actions:
		_dispatch_action(target, execution, result)


## Routes secondary damage through DamageService with shared depth/budget/visit safeguards.
## Other actions use the existing EffectService or the spatial world adapter.
static func _dispatch_action(target: Entity, execution: ElementalActionExecution, result: ElementalResolution) -> void:
	var action := execution.action
	if action == null:
		return
	match action.kind:
		ElementalAction.Kind.DAMAGE:
			if not result.chain.can_descend(result.depth):
				return
			var key := "%d|%s|%s" % [target.get_instance_id(), String(execution.rule_id), String(action.damage_type)]
			if not result.chain.claim(key):
				return
			var source := result.source if result.source == null or is_instance_valid(result.source) else null
			var request := DamageRequest.new(source, result.ability, action.magnitude(execution.strength), result.hit_position, result.direction, DamageRequest.Kind.PERIODIC, action.damage_type, 1.0 if action.allow_buildup else 0.0)
			request.chain = result.chain
			request.reaction_depth = result.depth + 1
			DamageService.request(target, request)
		ElementalAction.Kind.APPLY_EFFECT:
			EffectService.request(target, action.effect, result.source, result.ability)
		ElementalAction.Kind.SPAWN, ElementalAction.Kind.TRANSFORM:
			ElementalWorldActions.execute(target, execution, result, catalog())


## Synchronizes gauge-owned Effect Entities with their authoritative status lifetime.
## Existing effects are refreshed in place; unrelated EffectRuntime instances are never removed.
static func sync_effects(target: Entity) -> void:
	if ECS.world == null or target == null or not is_instance_valid(target):
		return
	var state := target.get_component(C_ElementalState) as C_ElementalState
	if state == null:
		return
	var definitions := catalog()
	for item in state.gauges:
		var definition := definitions.get_status(item.id)
		var active := state.is_active(item.id, definitions)
		if not active or definition == null or definition.effect == null:
			if item.effect_instance != null and is_instance_valid(item.effect_instance):
				EffectRuntime.remove(item.effect_instance)
			item.effect_instance = null
			item.synced_revision = item.revision
			continue
		if item.effect_instance == null or not is_instance_valid(item.effect_instance):
			var source := item.source if item.source == null or is_instance_valid(item.source) else null
			item.effect_instance = EffectRuntime.apply(target, EffectApplyRequest.new(definition.effect, source, item.ability))
		if item.effect_instance != null and is_instance_valid(item.effect_instance):
			var duration := item.effect_instance.get_component(C_Duration) as C_Duration
			if duration != null:
				duration.remaining = item.remaining
			item.synced_revision = item.revision
