## Typed result of one elemental resolution; negative signed_damage means healing before armor.
extends RefCounted
class_name ElementalResolution

var signed_damage: float = 0.0
var resistance: int = 0
var status_before: Array[StringName] = []
var status_after: Array[StringName] = []
var actions: Array[ElementalActionExecution] = []
var fired_rules: Array[StringName] = []
var truncated: bool = false


## Reports whether the active-status set changed during resolution.
func statuses_changed() -> bool:
	return status_before != status_after
