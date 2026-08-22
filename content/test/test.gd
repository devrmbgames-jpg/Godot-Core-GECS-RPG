## Integration scene для GECS groups, demo abilities и items.
extends Node

@export var world: World = null


func _ready() -> void:
	ECS.world = world
	var player := get_node_or_null("Entities/Player") as Entity
	if player != null:
		# Базовые слоты позволяют тестировать pipeline независимо от equipment.
		AbilityFactory.grant(player, DemoAbilityCatalog.attack(), &"primary")
		AbilityFactory.grant(player, DemoAbilityCatalog.shoot(), &"secondary")
		AbilityFactory.grant(player, DemoAbilityCatalog.fireball(), &"skill_1")
		var sword := ItemFactory.give(player, DemoItemCatalog.sword())
		ItemFactory.give(player, DemoItemCatalog.bow())
		ItemFactory.give(player, DemoItemCatalog.staff())
		EquipmentService.equip(player, sword)


func _process(delta: float) -> void:
	world.process(delta, "Attributes")
	world.process(delta, "Input")
	world.process(delta, "Gameplay")


func _physics_process(delta: float) -> void:
	world.process(delta, "Motion")
	world.process(delta, "Physics")
