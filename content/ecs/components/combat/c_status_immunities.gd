## Status immunity set kept separate from damage resistance semantics.
extends Component
class_name C_StatusImmunities

@export var status_ids: Array[StringName] = []


## Reports whether buildup and activation for the supplied status must be ignored.
func is_immune(status_id: StringName) -> bool:
	return status_id in status_ids


## Adds an immunity idempotently for runtime/effect adapters.
func add_immunity(status_id: StringName) -> void:
	if status_id != &"" and status_id not in status_ids:
		status_ids.append(status_id)


## Removes an immunity without changing any damage resistance.
func remove_immunity(status_id: StringName) -> void:
	status_ids.erase(status_id)
