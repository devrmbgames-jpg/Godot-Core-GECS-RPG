## Typed result of one elemental resolution. Negative signed_damage means healing before armor.
## The resolver owns gauge changes; an integration adapter consumes deferred action intents.
extends RefCounted
class_name ElementalResolution

var signed_damage: float = 0.0
var resistance: int = 0
var status_before: Array[StringName] = []
var status_after: Array[StringName] = []
var actions: Array[ElementalActionExecution] = []
var fired_rules: Array[StringName] = []
var changed: bool = false
var truncated: bool = false
var source: Entity
var ability: Entity
var hit_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var chain: ElementalChain
var depth: int = 0
var impact_strength: float = 0.0
var damage_type: StringName = &"PHYSICAL"


## Reports whether the active-status set changed during resolution.
func statuses_changed() -> bool:
	return status_before != status_after
