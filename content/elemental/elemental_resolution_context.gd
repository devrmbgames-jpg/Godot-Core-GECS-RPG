## Shared safety state for one root impact and every nested reaction it causes.
extends RefCounted
class_name ElementalResolutionContext

var max_actions: int = 64
var remaining_actions: int = 64
var max_depth: int = 8
var depth: int = 0
var processing_queue: bool = false
var action_queue: Array[ElementalQueuedAction] = []
var triggered_reaction_ids: Array[StringName] = []
var _reaction_fingerprints: PackedStringArray = PackedStringArray()


## Creates a bounded context; limits are normalized to at least one.
func _init(initial_max_actions: int = 64, initial_max_depth: int = 8) -> void:
	max_actions = maxi(initial_max_actions, 1)
	remaining_actions = max_actions
	max_depth = maxi(initial_max_depth, 1)


## Enters one nested resolver call and rejects work beyond max depth.
func try_enter() -> bool:
	if depth >= max_depth:
		return false
	depth += 1
	return true


## Leaves one resolver call without allowing negative depth.
func leave() -> void:
	depth = maxi(depth - 1, 0)


## Marks a reaction once per target and rule in this root chain.
func try_mark_reaction(target: Entity, reaction_id: StringName) -> bool:
	var target_id := target.get_instance_id() if target != null else 0
	var fingerprint := "%d:%s" % [target_id, String(reaction_id)]
	if fingerprint in _reaction_fingerprints:
		return false
	_reaction_fingerprints.append(fingerprint)
	triggered_reaction_ids.append(reaction_id)
	return true


## Queues an action while budget remains; execution consumes the budget separately.
func enqueue(action: ElementalQueuedAction) -> bool:
	if action == null or action_queue.size() >= remaining_actions:
		return false
	action_queue.append(action)
	return true


## Pops the next FIFO action and consumes one unit of the root action budget.
func pop_next() -> ElementalQueuedAction:
	if action_queue.is_empty() or remaining_actions <= 0:
		return null
	remaining_actions -= 1
	return action_queue.pop_front()
