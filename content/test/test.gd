## Integration scene для GECS groups и demo ARPG core.
extends Node

@export var world: World = null


func _ready() -> void:
	ECS.world = world
	var player := get_node_or_null("Entities/Player") as Entity
	var enemy := get_node_or_null("Entities/RigidActor") as Entity
	if player != null:
		(player.get_component(C_Team) as C_Team).team_id = &"player"
		AbilityFactory.grant(player, DemoAbilityCatalog.attack(), &"primary")
		AbilityFactory.grant(player, DemoAbilityCatalog.shoot(), &"secondary")
		AbilityFactory.grant(player, DemoAbilityCatalog.fireball(), &"skill_1")
		var sword := ItemFactory.give(player, DemoItemCatalog.sword())
		ItemFactory.give(player, DemoItemCatalog.bow())
		ItemFactory.give(player, DemoItemCatalog.staff())
		EquipmentService.equip(player, sword)
	if enemy != null and player != null:
		(enemy.get_component(C_Team) as C_Team).team_id = &"enemy"
		(enemy.get_component(C_AIChase) as C_AIChase).target = player
		AbilityFactory.grant(enemy, DemoAbilityCatalog.attack(), &"primary")


func _process(delta: float) -> void:
	world.process(delta, "Attributes")
	world.process(delta, "AI")
	world.process(delta, "Input")
	world.process(delta, "Gameplay")


func _physics_process(delta: float) -> void:
	world.process(delta, "Motion")
	world.process(delta, "Physics")
