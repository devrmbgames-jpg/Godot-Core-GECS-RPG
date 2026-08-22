## Integration scene для последовательности GECS groups и demo abilities.
extends Node

@export var world: World = null


func _ready() -> void:
	ECS.world = world
	var player := get_node_or_null("Entities/Player") as Entity
	if player != null:
		AbilityFactory.grant(player, DemoAbilityCatalog.attack(), &"primary")
		AbilityFactory.grant(player, DemoAbilityCatalog.shoot(), &"secondary")
		AbilityFactory.grant(player, DemoAbilityCatalog.fireball(), &"skill_1")


func _process(delta: float) -> void:
	world.process(delta, "Attributes")
	world.process(delta, "Input")
	world.process(delta, "Gameplay")


func _physics_process(delta: float) -> void:
	world.process(delta, "Motion")
	world.process(delta, "Physics")
