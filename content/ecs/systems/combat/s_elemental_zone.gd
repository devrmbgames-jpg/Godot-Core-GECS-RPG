## Pulses Area3D elemental zones into overlapping Entity targets and expires temporary zones.
## Area3D overlap is spatial authority; all damage/status mutation still goes through typed services.
extends System
class_name S_ElementalZone

const MAX_CATCH_UP_PULSES: int = 4


## Iterates spatial zones carrying immutable profile/runtime pulse data.
func query() -> QueryBuilder:
	return q.with_all([C_ElementalZone]).iterate([C_ElementalZone])


## Advances lifetime and pulse clocks, bounding catch-up work after long frames.
func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var zones: Array = components[0]
	for index in entities.size():
		var entity := entities[index]
		var zone := zones[index] as C_ElementalZone
		var area := entity as Node as Area3D
		if zone == null or zone.definition == null or area == null:
			cmd.remove_entity(entity)
			continue
		if zone.definition.duration > 0.0:
			zone.remaining -= delta
			if zone.remaining <= 0.0:
				cmd.remove_entity(entity)
				continue
		zone.tick_remaining -= delta
		var pulses := 0
		while zone.tick_remaining <= 0.0 and pulses < MAX_CATCH_UP_PULSES:
			zone.tick_remaining += maxf(zone.definition.tick_interval, 0.001)
			_pulse(entity, area, zone)
			pulses += 1
		if zone.tick_remaining <= 0.0:
			zone.tick_remaining = maxf(zone.definition.tick_interval, 0.001)


## Sends one profile payload to every unique overlapping Entity, including other elemental zones/surfaces.
func _pulse(owner: Entity, area: Area3D, zone: C_ElementalZone) -> void:
	var targets: Array[Entity] = []
	var seen: Dictionary = {}
	for body in area.get_overlapping_bodies():
		_append_entity(body as Node, owner, targets, seen)
	for overlap in area.get_overlapping_areas():
		_append_entity(overlap as Node, owner, targets, seen)
	for target in targets:
		_apply_profile(target, area.global_position, zone)


## Converts an overlap Node to its owning Entity and appends it once.
func _append_entity(node: Node, owner: Entity, targets: Array[Entity], seen: Dictionary) -> void:
	var current := node
	while current != null and not (current is Entity):
		current = current.get_parent()
	var target := current as Entity
	if target == null or target == owner or not is_instance_valid(target):
		return
	var key := target.get_instance_id()
	if seen.has(key):
		return
	seen[key] = true
	targets.append(target)


## Applies either one combined periodic damage request or status-only requests from the zone profile.
func _apply_profile(target: Entity, position: Vector3, zone: C_ElementalZone) -> void:
	var definition := zone.definition
	var source := null as Entity
	if not definition.affects_all and zone.source != null and is_instance_valid(zone.source):
		source = zone.source
	if definition.damage_amount > 0.0:
		DamageService.request(
			target,
			DamageRequest.new(
				source,
				zone.ability,
				definition.damage_amount,
				position,
				Vector3.ZERO,
				DamageRequest.Kind.PERIODIC,
				definition.damage_type,
				definition.buildup_scale,
				definition.status_applications,
			),
		)
		return
	for application in definition.status_applications:
		if application != null:
			ElementalService.apply_status(target, application.status_id, application.amount, source, zone.ability, definition.affects_all)
