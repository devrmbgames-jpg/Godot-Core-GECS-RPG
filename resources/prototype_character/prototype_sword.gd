## Prototype sword presentation prop.
##
## The scene is attached by CharacterRig through ItemDefinition.visual_scene. It is not
## a gameplay Item Entity; its only runtime responsibility is weapon-local presentation.
extends Node3D
class_name PrototypeSword

@onready var _trail_sword: Node3D = %TrailSword


## Shows or hides the sword trail child without changing equipment/gameplay state.
func set_enable_trail(enabled: bool) -> void:
	if _trail_sword != null:
		_trail_sword.visible = enabled
