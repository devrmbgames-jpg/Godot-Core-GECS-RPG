extends Node3D


@onready var _trail_sword := %TrailSword


func set_enable_trail(val: bool) -> void :
	_trail_sword.visible = val
