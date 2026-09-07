## ECS-authoritative elemental gauges, materials, damage resistances and independent status immunities.
## No physics transform, world registry or effect lifecycle is owned by this component.
extends Component
class_name C_ElementalState

@export var target_type: StringName = &"living"
@export var material: StringName = &""
@export var tags: Array[StringName] = []
@export var status_immunities: Array[StringName] = []

var gauges: Array[ElementalGauge] = []
var modifiers: Array[ElementalResistanceModifier] = []
var base_resistances: Dictionary = {}


## Returns a gauge, optionally creating its stable runtime record.
func gauge(id: StringName, create: bool = true) -> ElementalGauge:
	for item in gauges:
		if item.id == id:
			return item
	if not create or id == &"":
		return null
	var item := ElementalGauge.new(id)
	gauges.append(item)
	return item


## Reads accumulated strength without creating a record.
func get_amount(id: StringName) -> float:
	var item := gauge(id, false)
	return item.amount if item != null else 0.0


## Checks activation, including the independent status-immunity list.
func is_active(id: StringName, catalog: ElementalCatalog) -> bool:
	if status_immunities.has(id):
		return false
	var item := gauge(id, false)
	return item != null and item.is_active(catalog.get_status(id))


## Returns a stable snapshot of active status IDs for damage-multiplier evaluation.
func active_statuses(catalog: ElementalCatalog) -> Array[StringName]:
	var result: Array[StringName] = []
	for item in gauges:
		if is_active(item.id, catalog):
			result.append(item.id)
	result.sort()
	return result


## Reads a material tag, treating the primary material as an implicit tag.
func has_tag(id: StringName) -> bool:
	return material == id or tags.has(id)


## Adds buildup independently of damage resistance. Positive additions refresh the gauge lifetime.
## A zero or invalid addition never refreshes a status; immune statuses cannot accumulate.
func add_gauge(id: StringName, amount: float, catalog: ElementalCatalog, source: Entity = null, ability: Entity = null) -> float:
	var definition := catalog.get_status(id)
	if definition == null or status_immunities.has(id) or amount <= 0.0 or is_nan(amount) or is_inf(amount):
		return 0.0
	var item := gauge(id)
	var before := item.amount
	item.amount = minf(definition.max_gauge, before + amount)
	if item.amount <= before:
		return 0.0
	item.remaining = definition.duration
	item.source = source
	item.ability = ability
	item.revision += 1
	return item.amount - before


## Consumes no more than the available gauge strength, preserving any unspent remainder.
func consume_gauge(id: StringName, amount: float) -> float:
	var item := gauge(id, false)
	if item == null or amount <= 0.0 or is_nan(amount) or is_inf(amount):
		return 0.0
	var consumed := minf(item.amount, amount)
	if consumed <= 0.0:
		return 0.0
	item.amount -= consumed
	if item.amount <= 0.0001:
		item.amount = 0.0
		item.remaining = 0.0
	item.revision += 1
	return consumed


## Clears one gauge, including latent buildup, without removing its stable record.
func clear_gauge(id: StringName) -> void:
	var item := gauge(id, false)
	if item == null or (item.amount <= 0.0 and item.remaining <= 0.0):
		return
	item.amount = 0.0
	item.remaining = 0.0
	item.revision += 1


## Advances lifetimes and decay; expiration removes latent and active buildup alike.
func advance(delta: float, catalog: ElementalCatalog) -> void:
	if delta <= 0.0 or is_nan(delta) or is_inf(delta):
		return
	for item in gauges:
		var definition := catalog.get_status(item.id)
		if definition == null or item.amount <= 0.0:
			continue
		item.remaining = maxf(0.0, item.remaining - delta)
		if item.remaining <= 0.0:
			clear_gauge(item.id)
			continue
		if definition.decay_per_second > 0.0:
			consume_gauge(item.id, definition.decay_per_second * delta)


## Changes an independent status immunity; enabling it immediately clears existing buildup.
func set_status_immunity(id: StringName, immune: bool) -> void:
	if immune:
		if not status_immunities.has(id):
			status_immunities.append(id)
		clear_gauge(id)
	else:
		status_immunities.erase(id)


## Sets an individual base resistance override, clamped to the supported tier range.
func set_base_resistance(damage_type: StringName, value: int) -> void:
	base_resistances[damage_type] = clampi(value, -1, 4)


## Replaces one source/channel modifier instead of accumulating duplicate source records.
func set_modifier(modifier: ElementalResistanceModifier) -> void:
	if modifier == null:
		return
	remove_modifier(modifier.category, modifier.source_id, modifier.damage_type)
	if modifier.amount != 0:
		modifiers.append(modifier)


## Removes a specific modifier or all channels of a source when damage_type is empty.
func remove_modifier(category: StringName, source_id: StringName, damage_type: StringName = &"") -> void:
	for index in range(modifiers.size() - 1, -1, -1):
		var item := modifiers[index]
		if item.category == category and item.source_id == source_id and (damage_type == &"" or item.damage_type == damage_type):
			modifiers.remove_at(index)


## Resolves base plus strongest positive and negative modifier in each category, then clamps -1..4.
## Status-derived modifiers are evaluated live; sources in the same category do not sum.
func get_resistance(damage_type: StringName, catalog: ElementalCatalog) -> int:
	var base := int(base_resistances.get(damage_type, catalog.get_base_resistance(target_type, damage_type)))
	var all_modifiers: Array[ElementalResistanceModifier] = modifiers.duplicate()
	for status_id in active_statuses(catalog):
		var definition := catalog.get_status(status_id)
		for modifier in definition.resistance_modifiers:
			all_modifiers.append(modifier)
	var categories: Dictionary = {}
	for modifier in all_modifiers:
		if modifier == null or modifier.damage_type != damage_type:
			continue
		var pair: Vector2i = categories.get(modifier.category, Vector2i.ZERO)
		pair.x = mini(pair.x, modifier.amount)
		pair.y = maxi(pair.y, modifier.amount)
		categories[modifier.category] = pair
	for pair in categories.values():
		var values: Vector2i = pair
		base += values.x + values.y
	return clampi(base, -1, 4)
