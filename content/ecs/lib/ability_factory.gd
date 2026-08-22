## Stateless lifecycle helper для runtime Ability Entity.
##
## Вызывать из setup/bootstrap или через CommandBuffer custom operation, а не
## напрямую во время итерации другого System.
extends RefCounted
class_name AbilityFactory


static func grant(actor: Entity, definition: AbilityDefinition, slot: StringName) -> Entity:
	if ECS.world == null or actor == null or definition == null:
		return null
	var existing := find_ability(actor, slot)
	if existing != null:
		revoke(actor, existing)
	var ability := E_Ability.new()
	ability.name = "Ability_%s" % String(definition.id)
	ability.add_component(C_Ability.new(definition))
	ability.add_component(C_Cooldown.new())
	ability.add_component(C_EntityOwner.new(actor))
	ECS.world.add_entity(ability, null, false)
	actor.add_relationship(Relationship.new(R_HasAbility.new(ability, slot), E_Ability))
	return ability


static func revoke(actor: Entity, ability: Entity) -> void:
	if actor == null or ability == null:
		return
	for relationship in actor.get_relationships(Relationship.new(R_HasAbility.new(), E_Ability)):
		var data := relationship.relation as R_HasAbility
		if data != null and data.ability == ability:
			actor.remove_relationship(relationship, 1)
			break
	if ECS.world != null and is_instance_valid(ability):
		ECS.world.remove_entity(ability)


static func find_ability(actor: Entity, slot: StringName) -> Entity:
	if actor == null:
		return null
	for relationship in actor.get_relationships(Relationship.new(R_HasAbility.new(), E_Ability)):
		var data := relationship.relation as R_HasAbility
		if data != null and data.slot == slot and is_instance_valid(data.ability):
			return data.ability
	return null
