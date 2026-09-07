## ECS-authoritative elemental gauges, materials, resistances and independent status immunities.
## Physics, effect Entity lifecycles and spatial registries are owned by their existing systems.
extends Component
class_name C_ElementalState

@export var target_type: StringName = &"living"
@export var material: StringName = &""
## Explicit gameplay tags are preserved when a material changes.
@export var tags: Array[StringName] = []
## Material-derived tags are replaced atomically by the environment adapter.
var material_tags: Array[StringName] = []
@export var status_immunities: Array[StringName] = []

var gauges: Array[ElementalGauge] = []
var modifiers: Array[ElementalResistanceModifier] = []
var base_resistances: Dictionary = {}
## Changes to strength, activation, sources, material or resistance data increment this revision.
## Ordinary passage of time does not, so hot systems need not publish an event every frame.
var revision: int = 0


## Returns a stable gauge record, optionally creating it. NONE/empty is never a gauge.
func gauge(id: StringName, create: bool = true) -> ElementalGauge:
	for item in gauges:
		if item.id == id:
			return item
	if not create or id == &"" or id == &"NONE":
		return null
	var item := ElementalGauge.new(id)
	gauges.append(item)
	return item


## Reads accumulated strength without allocating a record.
func get_amount(id: StringName) -> float:
	var item := gauge(id, false)
	return item.amount if item != null else 0.0


## Checks the activation threshold, duration and independent status immunity.
func is_active(id: StringName, catalog: ElementalCatalog) -> bool:
	if status_immunities.has(id):
		return false
	var item := gauge(id, false)
	return item != null and item.is_active(catalog.get_status(id))


## Returns a sorted snapshot of active status IDs; latent buildup is excluded.
func active_statuses(catalog: ElementalCatalog) -> Array[StringName]:
	var result: Array[StringName] = []
	for item in gauges:
		if is_active(item.id, catalog):
			result.append(item.id)
	result.sort()
	return result


## Reads explicit, material-derived and implicit primary-material tags.
func has_tag(id: StringName) -> bool:
	return id != &"" and (material == id or tags.has(id) or material_tags.has(id))


## Adds nonnegative strength independently of HP resistance. Returns actual gained strength.
## A positive hit refreshes duration and source even at max_gauge; zero/invalid input never refreshes.
func add_gauge(id: StringName, amount: float, catalog: ElementalCatalog, source: Entity = null, ability: Entity = null) -> float:
	var definition := catalog.get_status(id)
	if definition == null or status_immunities.has(id) or not _positive_finite(amount):
		return 0.0
	var item := gauge(id)
	var before := item.amount
	var next_amount := minf(definition.max_gauge, before + amount)
	var changed := next_amount != before or item.remaining != definition.duration or item.source != source or item.ability != ability
	item.amount = next_amount
	item.remaining = definition.duration
	item.source = source
	item.ability = ability
	if changed:
		item.revision += 1
		revision += 1
	return next_amount - before


## Consumes at most the available strength, leaving any remainder and its lifetime intact.
func consume_gauge(id: StringName, amount: float) -> float:
	var item := gauge(id, false)
	if item == null or not _positive_finite(amount):
		return 0.0
	var consumed := minf(item.amount, amount)
	if consumed <= 0.0:
		return 0.0
	item.amount -= consumed
	if item.amount <= 0.0001:
		item.amount = 0.0
		item.remaining = 0.0
	item.revision += 1
	revision += 1
	return consumed


## Clears active and latent buildup without deleting its stable record or owned-effect reference.
func clear_gauge(id: StringName) -> void:
	var item := gauge(id, false)
	if item == null or (item.amount <= 0.0 and item.remaining <= 0.0):
		return
	item.amount = 0.0
	item.remaining = 0.0
	item.revision += 1
	revision += 1


## Advances finite positive time; expiration clears all buildup, decay consumes strength.
## Remaining time alone does not dirty the gameplay state; the lifecycle system synchronizes effects.
func advance(delta: float, catalog: ElementalCatalog) -> void:
	if not _positive_finite(delta):
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


## Changes an independent immunity; enabling it immediately clears existing buildup.
func set_status_immunity(id: StringName, immune: bool) -> void:
	if id == &"" or id == &"NONE":
		return
	if immune:
		if not status_immunities.has(id):
			status_immunities.append(id)
			revision += 1
		clear_gauge(id)
	elif status_immunities.has(id):
		status_immunities.erase(id)
		revision += 1


## Replaces the primary material and its derived tags, preserving explicit gameplay tags.
func set_material(id: StringName, derived_tags: Array[StringName] = []) -> bool:
	var normalized: Array[StringName] = []
	for tag in derived_tags:
		if tag != &"" and not normalized.has(tag):
			normalized.append(tag)
	normalized.sort()
	if material == id and material_tags == normalized:
		return false
	material = id
	material_tags = normalized
	revision += 1
	return true


## Adds an explicit tag without changing material-derived tags.
func add_tag(id: StringName) -> bool:
	if id == &"" or tags.has(id):
		return false
	tags.append(id)
	revision += 1
	return true


## Removes one explicit tag; intrinsic material tags remain controlled by the material profile.
func remove_tag(id: StringName) -> bool:
	if not tags.has(id):
		return false
	tags.erase(id)
	revision += 1
	return true


## Sets an individual base resistance override, clamped to the supported -1..4 range.
func set_base_resistance(damage_type: StringName, value: int) -> void:
	var next_value := clampi(value, -1, 4)
	if int(base_resistances.get(damage_type, -999)) != next_value:
		base_resistances[damage_type] = next_value
		revision += 1


## Replaces one category/source/channel modifier; the record is copied to prevent external mutation.
func set_modifier(modifier: ElementalResistanceModifier) -> void:
	if modifier == null:
		return
	remove_modifier(modifier.category, modifier.source_id, modifier.damage_type)
	if modifier.amount != 0:
		modifiers.append(modifier.duplicate(true) as ElementalResistanceModifier)
		revision += 1


## Removes one source's modifier, or every channel of that source when damage_type is empty.
func remove_modifier(category: StringName, source_id: StringName, damage_type: StringName = &"") -> void:
	for index in range(modifiers.size() - 1, -1, -1):
		var item := modifiers[index]
		if item.category == category and item.source_id == source_id and (damage_type == &"" or item.damage_type == damage_type):
			modifiers.remove_at(index)
			revision += 1


## Returns base plus strongest negative and positive modifier per category, clamped only at the end.
## Status-derived modifiers are evaluated live; status immunity is not a damage resistance.
func get_resistance(damage_type: StringName, catalog: ElementalCatalog) -> int:
	var base := int(base_resistances.get(damage_type, catalog.get_base_resistance(target_type, damage_type)))
	var all_modifiers: Array[ElementalResistanceModifier] = modifiers.duplicate()
	for status_id in active_statuses(catalog):
		var definition := catalog.get_status(status_id)
		if definition != null:
			all_modifiers.append_array(definition.resistance_modifiers)
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


## Rejects zero, negative, NaN and infinite strengths or time deltas.
static func _positive_finite(value: float) -> bool:
	return value > 0.0 and not is_nan(value) and not is_inf(value)
