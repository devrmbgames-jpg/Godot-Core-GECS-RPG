## Реактивно помечает target Entity dirty при добавлении/удалении R_ModifiesStat.
##
## Благодаря Observer не нужен постоянный polling modifiers. Структурную мутацию
## C_StatsDirty выполняем через CommandBuffer, чтобы не создавать re-entrant cascade.
extends Observer
class_name O_StatModifierChanged


func query() -> QueryBuilder:
	return q.on_relationship_added([R_ModifiesStat]).on_relationship_removed([R_ModifiesStat])


func each(_event: Variant, _source: Entity, payload: Variant) -> void:
	var relationship := payload as Relationship
	if relationship == null:
		return
	var target := relationship.target as Entity
	var modifier := relationship.relation as R_ModifiesStat
	if target == null or modifier == null:
		return
	var dirty := target.get_component(C_StatsDirty) as C_StatsDirty
	if dirty != null:
		dirty.mark(modifier.stat_type)
	else:
		cmd.add_component(target, C_StatsDirty.new(modifier.stat_type))
