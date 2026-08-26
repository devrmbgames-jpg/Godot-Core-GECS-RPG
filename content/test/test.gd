## Полная primitive integration scene для ручной проверки ARPG core.
##
## Все spatial Entity/physics objects уже размещены в test.tscn. Код только связывает
## существующие nodes и выдаёт стартовые runtime loadouts — позиции здесь не задаются.
extends Node

@export var world: World = null


## Назначает ECS.world и откладывает demo linking до завершения scene-tree initialization.
func _ready() -> void:
	ECS.world = world
	call_deferred("_configure_demo")


## Выдаёт заранее размещённым actors demo abilities/loadouts и связывает AI chase targets.
## Spatial nodes не создаются и не позиционируются этим методом.
func _configure_demo() -> void:
	var player := get_node_or_null("Entities/Player") as Entity
	var warrior := get_node_or_null("Entities/RigidWarrior") as Entity
	var archer := get_node_or_null("Entities/RigidArcher") as Entity
	var mage := get_node_or_null("Entities/RigidMage") as Entity
	var actors: Array[Entity] = [player, warrior, archer, mage]
	for actor in actors:
		if actor == null:
			continue
		AbilityFactory.grant(actor, DemoAbilityCatalog.shoot(), &"secondary")
		AbilityFactory.grant(actor, DemoAbilityCatalog.fireball(), &"skill_1")
	_equip_new(player, DemoItemCatalog.sword())
	_equip_new(warrior, DemoItemCatalog.sword())
	_equip_new(archer, DemoItemCatalog.bow())
	_equip_new(mage, DemoItemCatalog.staff())
	for actor in [warrior, archer, mage]:
		if actor == null or player == null:
			continue
		var chase := actor.get_component(C_AIChase) as C_AIChase
		if chase != null:
			chase.target = player


## Создаёт runtime inventory item по definition и отправляет обычный equipment request actor.
func _equip_new(actor: Entity, definition: ItemDefinition) -> void:
	if actor == null or definition == null:
		return
	var item := ItemFactory.give(actor, definition)
	if item != null:
		EquipmentService.equip(actor, item)


## Выполняет process-groups в dependency order: Attributes -> Combat -> AI -> Input -> Gameplay -> Presentation.
func _process(delta: float) -> void:
	world.process(delta, "Attributes")
	world.process(delta, "Combat")
	world.process(delta, "AI")
	world.process(delta, "Input")
	world.process(delta, "Gameplay")
	world.process(delta, "Presentation")


## Выполняет physics groups после frame intent/gameplay: Motion -> Physics.
func _physics_process(delta: float) -> void:
	world.process(delta, "Motion")
	world.process(delta, "Physics")
