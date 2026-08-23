## Пересчитывает только Entity, помеченные C_StatsDirty.
##
## Gameplay systems всегда читают готовые AttributeComponent.value. После rebuild
## marker удаляется через CommandBuffer, поэтому система не работает без причины.
extends System
class_name S_StatRebuild


func query() -> QueryBuilder:
	return q.with_all([C_StatsDirty])


func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
	for entity in entities:
		var dirty := entity.get_component(C_StatsDirty) as C_StatsDirty
		if dirty == null or dirty.requests_full_rebuild():
			StatResolver.resolve_all(entity)
		else:
			StatResolver.resolve_types(entity, dirty.stat_types)
		cmd.remove_component(entity, C_StatsDirty)
