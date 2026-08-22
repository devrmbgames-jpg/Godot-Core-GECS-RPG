## Типизированный event успешного resolve Ability Entity.
extends RefCounted
class_name AbilityResolvedEvent

## Runtime Ability Entity, которая была resolved.
var ability: Entity

## Immutable design definition resolved ability.
var definition: AbilityDefinition


func _init(initial_ability: Entity, initial_definition: AbilityDefinition) -> void:
	ability = initial_ability
	definition = initial_definition
