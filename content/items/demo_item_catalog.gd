## Demo weapon definitions: Sword, Bow, Staff.
extends RefCounted
class_name DemoItemCatalog

const PROTOTYPE_SWORD_SCENE: PackedScene = preload("res://resources/prototype_character/prototype_sword.tscn")


## Создаёт Sword definition: +10 Damage, primary melee Attack и prototype visual в main-hand socket.
static func sword() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.id = &"sword"; item.display_name = "Sword"; item.equipment_slot = &"main_hand"
	item.stat_modifiers = [StatModifierDefinition.new(C_Damage, R_ModifiesStat.Operation.ADDED, 10.0)]
	item.granted_abilities = [GrantedAbilityDefinition.new(DemoAbilityCatalog.attack(), &"primary")]
	item.visual_scene = PROTOTYPE_SWORD_SCENE
	item.rig_socket = &"main_hand"
	return item


## Создаёт Bow definition: Damage/AttackSpeed modifiers и primary Shoot.
static func bow() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.id = &"bow"; item.display_name = "Bow"; item.equipment_slot = &"main_hand"
	item.stat_modifiers = [
		StatModifierDefinition.new(C_Damage, R_ModifiesStat.Operation.ADDED, 4.0),
		StatModifierDefinition.new(C_AttackSpeed, R_ModifiesStat.Operation.INCREASED, 0.15),
	]
	item.granted_abilities = [GrantedAbilityDefinition.new(DemoAbilityCatalog.shoot(), &"primary")]
	return item


## Создаёт Magic Staff definition: +Damage, reduced mana cost и primary Fireball.
static func staff() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.id = &"staff"; item.display_name = "Magic Staff"; item.equipment_slot = &"main_hand"
	item.stat_modifiers = [
		StatModifierDefinition.new(C_Damage, R_ModifiesStat.Operation.ADDED, 15.0),
		StatModifierDefinition.new(C_ManaCostMultiplier, R_ModifiesStat.Operation.MORE, 0.85),
	]
	item.granted_abilities = [GrantedAbilityDefinition.new(DemoAbilityCatalog.fireball(), &"primary")]
	return item
