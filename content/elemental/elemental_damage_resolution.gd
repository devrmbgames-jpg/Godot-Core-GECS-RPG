## Typed calculation trace for one elemental DamageRequest.
extends RefCounted
class_name ElementalDamageResolution

var damage_type: StringName = ElementalIds.DAMAGE_PHYSICAL
var raw_amount: float = 0.0
var status_multiplier: float = 1.0
var resistance_level: int = 0
var resistance_multiplier: float = 1.0
var health_amount_before_armor: float = 0.0
var health_damage_after_armor: float = 0.0
var healing_requested: float = 0.0
var buildup_applied: float = 0.0
var buildup_transition: ElementalStatusTransition
var triggered_reactions: Array[StringName] = []


## Creates an empty trace with normalized raw damage.
func _init(initial_damage_type: StringName = ElementalIds.DAMAGE_PHYSICAL, initial_raw_amount: float = 0.0) -> void:
	damage_type = initial_damage_type
	raw_amount = maxf(initial_raw_amount, 0.0)
