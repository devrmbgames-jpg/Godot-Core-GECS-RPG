## Stateless helper для редкого пересчёта resolved attributes.
##
## Класс не хранит gameplay state и не является AttributeManager. Он собирает
## R_ModifiesStat, применяет формулу и записывает готовое значение в AttributeComponent.
extends RefCounted
class_name StatResolver


## Пересчитывает все AttributeComponent на [param actor].
static func resolve_all(actor: Entity) -> void:
	if actor == null:
		return
	var modifiers := _collect_modifiers(actor)
	for component in actor.components.values():
		var stat := component as AttributeComponent
		if stat != null:
			_resolve_stat(stat, modifiers)


## Пересчитывает только перечисленные stat scripts.
static func resolve_types(actor: Entity, stat_types: Array[Script]) -> void:
	if actor == null:
		return
	if stat_types.is_empty():
		resolve_all(actor)
		return
	var modifiers := _collect_modifiers(actor)
	for stat_type in stat_types:
		var stat := actor.get_component(stat_type) as AttributeComponent
		if stat != null:
			_resolve_stat(stat, modifiers)


## Формула: (base + sum(ADDED)) * (1 + sum(INCREASED)) * product(MORE).
static func _resolve_stat(stat: AttributeComponent, modifiers: Array[R_ModifiesStat]) -> void:
	var added := 0.0
	var increased := 0.0
	var more := 1.0
	var stat_script := stat.get_script()
	for modifier in modifiers:
		if modifier.stat_type != stat_script:
			continue
		match modifier.operation:
			R_ModifiesStat.Operation.ADDED:
				added += modifier.amount
			R_ModifiesStat.Operation.INCREASED:
				increased += modifier.amount
			R_ModifiesStat.Operation.MORE:
				more *= modifier.amount
	stat.value = (stat.base_value + added) * (1.0 + increased) * more


## Собирает modifier relations со всех source Entity, направленных на actor.
## Этот поиск выполняется только для dirty actor, а не в каждом gameplay hot path.
static func _collect_modifiers(actor: Entity) -> Array[R_ModifiesStat]:
	var result: Array[R_ModifiesStat] = []
	if ECS.world == null:
		return result
	var pattern := Relationship.new(R_ModifiesStat.new(), actor)
	var sources := ECS.world.query.with_relationship([pattern]).execute()
	for source in sources:
		for relationship in source.get_relationships(pattern):
			var modifier := relationship.relation as R_ModifiesStat
			if modifier != null and modifier.stat_type != null:
				result.append(modifier)
	return result
