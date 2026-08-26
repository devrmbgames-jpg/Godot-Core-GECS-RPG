## Один typed mapping semantic gameplay action -> animation/state name конкретного rig.
extends Resource
class_name RigActionBinding

@export var action: StringName = &""
@export var animation: StringName = &""


## Создаёт typed semantic-action mapping для RigProfile.
func _init(initial_action: StringName = &"", initial_animation: StringName = &"") -> void:
	action = initial_action
	animation = initial_animation
