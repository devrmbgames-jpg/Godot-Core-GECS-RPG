## Immutable design-time описание предмета.
extends Resource
class_name ItemDefinition

@export var id: StringName = &"item"
@export var display_name: String = "Item"
@export var equipment_slot: StringName = &"main_hand"
@export var stat_modifiers: Array[StatModifierDefinition] = []
@export var granted_abilities: Array[GrantedAbilityDefinition] = []

@export_group("Presentation")
## Optional visual prop instantiated by CharacterRig when this item is equipped.
@export var visual_scene: PackedScene
## Semantic CharacterRig socket that receives visual_scene.
@export var rig_socket: StringName = &"main_hand"
