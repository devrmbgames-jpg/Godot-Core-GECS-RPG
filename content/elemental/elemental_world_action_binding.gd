## Scene/effect adapter row for one semantic reaction action ID.
##
## Core data stays free of PackedScene references; a concrete world owns these bindings.
extends Resource
class_name ElementalWorldActionBinding

@export var semantic_id: StringName = &""
@export var spawn_scene: PackedScene
@export var effect_definition: EffectDefinition
