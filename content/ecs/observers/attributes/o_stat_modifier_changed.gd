## Реактивно помечает actor dirty при добавлении/удалении R_ModifiesStat.
##
## Relationship source является владельцем stat, target — stat Script. Благодаря
## Observer не нужен polling modifiers; structural mutation marker идёт через cmd.
extends Observer
class_name O_StatModifierChanged


func query() -> QueryBuilder:
	return q.on_relationship_added([R_ModifiesStat]).on_relationship_removed([R_ModifiesStat])


func each(_event: Variant, actor: Entity, payload: Variant) -> void:
	var relationship := payload as Relationship
	if actor == null or relationship == null or not (relationship.target is Script):
		return
	var stat_type := relationship.target as Script
	var dirty := actor.get_component(C_StatsDirty) as C_StatsDirty
	if dirty != null:
		dirty.mark(stat_type)
	else:
		cmd.add_component(actor, C_StatsDirty.new(stat_type))
