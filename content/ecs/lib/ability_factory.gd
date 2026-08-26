## Stateless lifecycle helper для runtime Ability Entity.
extends RefCounted
class_name AbilityFactory


## Создаёт off-tree runtime ability для semantic slot. Existing ability того же slot
## сначала revoke-ится; optional grant_source позволяет позже снять grants конкретного item/passive.
static func grant(
	actor: Entity,
	definition: AbilityDefinition,
	slot: StringName,
	grant_source: Entity = null,
) -> Entity:
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
	if grant_source != null:
		ability.add_component(C_GrantedBy.new(grant_source))
	ECS.world.add_entity(ability, null, false)
	actor.add_relationship(Relationship.new(R_HasAbility.new(ability, slot), E_Ability))
	return ability


## Удаляет actor R_HasAbility relation и runtime Ability Entity из ECS.world.
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


## Снимает все runtime abilities actor, у которых C_GrantedBy.source совпадает с source.
static func revoke_by_source(actor: Entity, source: Entity) -> void:
	if actor == null or source == null:
		return
	var to_revoke: Array[Entity] = []
	for relationship in actor.get_relationships(Relationship.new(R_HasAbility.new(), E_Ability)):
		var data := relationship.relation as R_HasAbility
		if data == null or data.ability == null or not is_instance_valid(data.ability):
			continue
		var granted_by := data.ability.get_component(C_GrantedBy) as C_GrantedBy
		if granted_by != null and granted_by.source == source:
			to_revoke.append(data.ability)
	for ability in to_revoke:
		revoke(actor, ability)


## Возвращает живую runtime Ability Entity, назначенную semantic slot actor, либо null.
static func find_ability(actor: Entity, slot: StringName) -> Entity:
	if actor == null:
		return null
	for relationship in actor.get_relationships(Relationship.new(R_HasAbility.new(), E_Ability)):
		var data := relationship.relation as R_HasAbility
		if data != null and data.slot == slot and is_instance_valid(data.ability):
			return data.ability
	return null
