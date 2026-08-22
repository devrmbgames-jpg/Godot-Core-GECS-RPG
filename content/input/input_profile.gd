## Настраиваемый набор semantic InputMap actions для локального игрока.
##
## Resource не хранит нажатия: он только связывает gameplay intents с именами
## Godot InputMap, поэтому bindings можно переназначать без изменения systems.
extends Resource
class_name InputProfile

@export_group("Movement")
@export var move_left: StringName = &"game_move_left"
@export var move_right: StringName = &"game_move_right"
@export var move_forward: StringName = &"game_move_forward"
@export var move_backward: StringName = &"game_move_backward"

@export_group("Actions")
@export var primary_action: StringName = &"game_primary_action"
@export var secondary_action: StringName = &"game_secondary_action"
@export var skill_1_action: StringName = &"game_skill_1"
@export var interact: StringName = &"game_interact"
