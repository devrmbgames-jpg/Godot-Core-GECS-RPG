## Immutable design-time описание предмета.
extends Resource
class_name ItemDefinition

@export var id: StringName = &"item"
@export var display_name: String = "Item"
@export var equipment_slot: StringName = &"main_hand"
@export var stat_modifiers: Array[StatModifierDefinition] = []
@export var granted_abilities: Array[GrantedAbilityDefinition] = []

@export_group("Presentation")
@export var visual_scene: PackedScene
@export var rig_socket: StringName = &"main_hand"
