extends Node

@export var world: World = null


func _ready() -> void:
	ECS.world = world

func _process(delta: float) -> void:
	world.process(delta, "Input")
	

func _physics_process(delta: float) -> void:
	world.process(delta, "Physics")
	world.process(delta, "Motion")
