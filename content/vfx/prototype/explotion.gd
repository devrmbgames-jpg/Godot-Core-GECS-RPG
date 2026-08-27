extends Node3D

@onready var _particle := $GPUParticles3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_particle.emitting = true
