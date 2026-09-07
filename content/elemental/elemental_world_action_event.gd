## Typed semantic world/presentation action emitted by reaction execution.
##
## Environment adapters map semantic_id to a scene, surface definition or VFX.
extends RefCounted
class_name ElementalWorldActionEvent

var target: Entity
var source: Entity
var ability: Entity
var kind: ElementalReactionActionDefinition.Kind
var semantic_id: StringName = &""
var amount: float = 0.0
var hit_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO


## Creates a world-facing action without embedding PackedScene or scene-tree ownership.
func _init(
	initial_target: Entity = null,
	initial_source: Entity = null,
	initial_ability: Entity = null,
	initial_kind: ElementalReactionActionDefinition.Kind = ElementalReactionActionDefinition.Kind.EMIT_EFFECT,
	initial_semantic_id: StringName = &"",
	initial_amount: float = 0.0,
	initial_hit_position: Vector3 = Vector3.ZERO,
	initial_direction: Vector3 = Vector3.ZERO,
) -> void:
	target = initial_target
	source = initial_source
	ability = initial_ability
	kind = initial_kind
	semantic_id = initial_semantic_id
	amount = initial_amount
	hit_position = initial_hit_position
	direction = initial_direction
