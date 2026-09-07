## Runtime buildup, activity and lifetime for one status on one subject.
extends RefCounted
class_name ElementalStatusState

var definition: ElementalStatusDefinition
var buildup: float = 0.0
var active: bool = false
var remaining_duration: float = 0.0
var source: Entity
var ability: Entity


## Creates empty runtime state bound to an immutable definition snapshot.
func _init(initial_definition: ElementalStatusDefinition = null) -> void:
	definition = initial_definition


## Applies signed buildup, refreshes active duration on positive input and returns a transition snapshot.
func apply_delta(amount: float, initial_source: Entity = null, initial_ability: Entity = null) -> ElementalStatusTransition:
	if definition == null:
		return ElementalStatusTransition.new()
	var previous := buildup
	var was_active := active
	buildup = clampf(buildup + amount, 0.0, definition.max_buildup)
	if amount > 0.0:
		source = initial_source
		ability = initial_ability
		if buildup >= definition.activation_threshold:
			active = true
		if active and definition.duration > 0.0:
			remaining_duration = definition.duration
	if active and buildup <= definition.deactivation_threshold:
		active = false
		remaining_duration = 0.0
	return ElementalStatusTransition.new(definition.id, previous, buildup, not was_active and active, was_active and not active)


## Advances duration and decay; duration expiry clears buildup to avoid immediate reactivation.
func advance(delta: float) -> ElementalStatusTransition:
	if definition == null:
		return ElementalStatusTransition.new()
	var previous := buildup
	var was_active := active
	var step := maxf(delta, 0.0)
	if active and definition.duration > 0.0:
		remaining_duration = maxf(remaining_duration - step, 0.0)
		if remaining_duration <= 0.0:
			buildup = 0.0
			active = false
	if buildup > 0.0 and definition.decay_per_second > 0.0:
		buildup = maxf(0.0, buildup - definition.decay_per_second * step)
	if active and buildup <= definition.deactivation_threshold:
		active = false
		remaining_duration = 0.0
	return ElementalStatusTransition.new(definition.id, previous, buildup, not was_active and active, was_active and not active)
