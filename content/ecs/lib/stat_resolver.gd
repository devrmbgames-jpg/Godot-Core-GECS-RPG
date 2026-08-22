## Stateless helper для редкого пересчёта resolved attributes.
##
## Класс не хранит gameplay state и не является AttributeManager. Он читает
## локальные R_ModifiesStat relationships actor и записывает готовые AttributeComponent.value.
extends RefCounted
class_name StatResolver


## Пересчитывает все AttributeComponent на [param actor].
static func resolve_all(actor: Entity) -> void:
	if actor == null:
		return
	var relationships := actor.get_relationships(Relationship.new(R_ModifiesStat.new(), null))
	for component in actor.components.values():
		var stat := component as AttributeComponent
		if stat != null:
			_resolve_stat(stat, relationships)


## Пересчитывает только перечисленные stat scripts.
static func resolve_types(actor: Entity, stat_types: Array[Script]) -> void:
	if actor == null:
		return
	if stat_types.is_empty():
		resolve_all(actor)
		return
	var relationships := actor.get_relationships(Relationship.new(R_ModifiesStat.new(), null))
	for stat_type in stat_types:
		var stat := actor.get_component(stat_type) as AttributeComponent
		if stat != null:
			_resolve_stat(stat, relationships)


## Формула: (base + sum(ADDED)) * (1 + sum(INCREASED)) * product(MORE).
static func _resolve_stat(stat: AttributeComponent, relationships: Array[Relationship]) -> void:
	var added := 0.0
	var increased := 0.0
	var more := 1.0
	var stat_script: Script = stat.get_script()
	for relationship in relationships:
		if relationship.target != stat_script:
			continue
		var modifier := relationship.relation as R_ModifiesStat
		if modifier == null:
			continue
		match modifier.operation:
			R_ModifiesStat.Operation.ADDED:
				added += modifier.amount
			R_ModifiesStat.Operation.INCREASED:
				increased += modifier.amount
			R_ModifiesStat.Operation.MORE:
				more *= modifier.amount
	stat.value = (stat.base_value + added) * (1.0 + increased) * more
