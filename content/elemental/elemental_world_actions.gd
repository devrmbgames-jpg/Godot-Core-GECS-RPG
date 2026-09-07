## Godot spatial adapter for elemental Spawn/Transform actions.
## Resolver rules never instantiate scenes or mutate Area3D state directly.
extends RefCounted
class_name ElementalWorldActions

const GENERIC_ZONE_SCENE: PackedScene = preload("res://content/ecs/entities/combat/e_elemental_zone.tscn")


## Executes one deferred spatial action against the resolved target and hit context.
static func execute(target: Entity, execution: ElementalActionExecution, result: ElementalResolution, elements: ElementalCatalog) -> void:
	if ECS.world == null or target == null or execution == null or execution.action == null or result == null:
		return
	match execution.action.kind:
		ElementalAction.Kind.SPAWN:
			_spawn(execution.action.entity_id, target, result, elements)
		ElementalAction.Kind.TRANSFORM:
			_transform(target, execution.action.material_id)


## Applies a material profile to an existing elemental target while preserving explicit gameplay tags.
static func _transform(target: Entity, profile_id: StringName) -> void:
	var state := target.get_component(C_ElementalState) as C_ElementalState
	if state == null or profile_id == &"":
		return
	var profile := ElementalService.environment_catalog().get_definition(profile_id)
	if profile != null:
		state.set_material(profile.material_id, profile.tags)
	else:
		state.set_material(profile_id)


## Creates a generic Area3D zone from a typed environment profile at the impact or target position.
static func _spawn(profile_id: StringName, target: Entity, result: ElementalResolution, elements: ElementalCatalog) -> Entity:
	var environment := ElementalService.environment_catalog()
	var profile := environment.get_definition(profile_id)
	if profile == null or not profile.is_valid_definition() or not environment.validate(elements).is_empty():
		return null
	var zone := GENERIC_ZONE_SCENE.instantiate() as Entity
	if zone == null:
		return null
	var area := zone as Area3D
	if area == null:
		zone.free()
		return null
	var position := result.hit_position
	if position == Vector3.ZERO:
		var target_node := target as Node as Node3D
		if target_node != null:
			position = target_node.global_position
	area.global_position = position
	_configure_radius(area, profile.radius)
	var state := zone.get_component(C_ElementalState) as C_ElementalState
	if state == null:
		state = C_ElementalState.new()
		zone.add_component(state)
	state.set_material(profile.material_id, profile.tags)
	zone.add_component(C_ElementalZone.new(profile, result.source, result.ability))
	_attach_visual(area, profile.scene)
	ECS.world.add_entity(zone)
	return zone


## Duplicates the generic collision shape so each spawned zone can have an independent radius.
static func _configure_radius(area: Area3D, radius: float) -> void:
	var collision := area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision == null or collision.shape == null:
		return
	var shape := collision.shape.duplicate() as SphereShape3D
	if shape == null:
		return
	shape.radius = maxf(radius, 0.001)
	collision.shape = shape


## Attaches optional profile-specific visual content as presentation-only child data.
static func _attach_visual(area: Area3D, scene: PackedScene) -> void:
	if scene == null:
		return
	var visual := scene.instantiate()
	if visual == null:
		return
	area.add_child(visual)
