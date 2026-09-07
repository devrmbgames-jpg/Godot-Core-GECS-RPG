## Mutable per-target status strength, lifetime and owned Effect Entity reference.
extends RefCounted
class_name ElementalGauge

var id: StringName = &""
var amount: float = 0.0
var remaining: float = 0.0
var source: Entity
var ability: Entity
var effect_instance: Entity
var revision: int = 0
var synced_revision: int = -1


## Creates an empty gauge without activating its status.
func _init(initial_id: StringName = &"") -> void:
	id = initial_id


## Returns whether the gauge currently satisfies its definition's activation threshold.
func is_active(definition: ElementalStatusDefinition) -> bool:
	return definition != null and amount >= definition.threshold and remaining > 0.0
