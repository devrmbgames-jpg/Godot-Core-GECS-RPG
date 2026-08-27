## Prototype one-shot impact VFX.
##
## Starts its GPUParticles3D on entry and frees the VFX root after the particle lifetime.
## Gameplay/collision state is owned elsewhere; this scene owns only its visual lifetime.
extends Node3D
class_name PrototypeExplosionVFX

@onready var _particle: GPUParticles3D = $GPUParticles3D


## Starts the one-shot emission and schedules cleanup after all particles have had time to finish.
func _ready() -> void:
	if _particle == null:
		queue_free()
		return
	_particle.emitting = true
	await get_tree().create_timer(maxf(_particle.lifetime, 0.0) + 0.25).timeout
	if is_instance_valid(self):
		queue_free()
