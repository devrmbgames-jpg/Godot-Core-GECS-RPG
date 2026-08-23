## Design-time ability grant от item/passive.
extends Resource
class_name GrantedAbilityDefinition

@export var ability: AbilityDefinition
@export var slot: StringName = &"primary"


func _init(initial_ability: AbilityDefinition = null, initial_slot: StringName = &"primary") -> void:
	ability = initial_ability
	slot = initial_slot
