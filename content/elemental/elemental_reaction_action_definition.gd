## Immutable action emitted by a reaction rule.
##
## Numeric amount can be fixed or multiplied by the reaction power. Semantic world IDs
## are resolved by a presentation/environment adapter, not by core gameplay.
extends Resource
class_name ElementalReactionActionDefinition

enum Kind {
	MODIFY_STATUS,
	APPLY_STATUS,
	REMOVE_STATUS,
	DEAL_DAMAGE,
	SPAWN_ENTITY,
	TRANSFORM_SURFACE,
	ADD_MATERIAL,
	REMOVE_MATERIAL,
	EMIT_EFFECT,
}

@export var kind: Kind = Kind.MODIFY_STATUS
@export var status_id: StringName = &""
@export var damage_type: StringName = &""
@export var semantic_id: StringName = &""
@export var amount: float = 0.0
@export var scale_with_reaction_power: bool = false


## Returns the action magnitude for a concrete reaction power.
func resolve_amount(reaction_power: float) -> float:
	if scale_with_reaction_power:
		return amount * reaction_power
	return amount
