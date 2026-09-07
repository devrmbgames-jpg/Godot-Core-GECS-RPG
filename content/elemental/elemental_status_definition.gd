## Immutable design-time definition of a status gauge and its optional gameplay effect.
extends Resource
class_name ElementalStatusDefinition

@export var id: StringName = &""
@export_range(0.001, 100000.0) var threshold: float = 20.0
@export_range(0.001, 100000.0) var max_gauge: float = 200.0
@export var duration: float = 8.0
@export var decay_per_second: float = 0.0
@export var effect: EffectDefinition
@export var resistance_modifiers: Array[ElementalResistanceModifier] = []


## Validates the numeric invariants required by the gauge resolver.
func is_valid_definition() -> bool:
	return id != &"" and threshold > 0.0 and max_gauge >= threshold and duration > 0.0 and decay_per_second >= 0.0
