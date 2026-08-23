## Demo weapon definitions: Sword, Bow, Staff.
extends RefCounted
class_name DemoItemCatalog


static func sword() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.id = &"sword"; item.display_name = "Sword"; item.equipment_slot = &"main_hand"
	item.stat_modifiers = [StatModifierDefinition.new(C_Damage, R_ModifiesStat.Operation.ADDED, 10.0)]
	item.granted_abilities = [GrantedAbilityDefinition.new(DemoAbilityCatalog.attack(), &"primary")]
	return item


static func bow() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.id = &"bow"; item.display_name = "Bow"; item.equipment_slot = &"main_hand"
	item.stat_modifiers = [
		StatModifierDefinition.new(C_Damage, R_ModifiesStat.Operation.ADDED, 4.0),
		StatModifierDefinition.new(C_AttackSpeed, R_ModifiesStat.Operation.INCREASED, 0.15),
	]
	item.granted_abilities = [GrantedAbilityDefinition.new(DemoAbilityCatalog.shoot(), &"primary")]
	return item


static func staff() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.id = &"staff"; item.display_name = "Magic Staff"; item.equipment_slot = &"main_hand"
	item.stat_modifiers = [
		StatModifierDefinition.new(C_Damage, R_ModifiesStat.Operation.ADDED, 15.0),
		StatModifierDefinition.new(C_ManaCostMultiplier, R_ModifiesStat.Operation.MORE, 0.85),
	]
	item.granted_abilities = [GrantedAbilityDefinition.new(DemoAbilityCatalog.fireball(), &"primary")]
	return item
