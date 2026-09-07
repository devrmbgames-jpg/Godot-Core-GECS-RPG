## Typed deferred action intent produced by the resolver and consumed by an integration adapter.
extends RefCounted
class_name ElementalActionExecution

var action: ElementalAction
var strength: float = 0.0
var rule_id: StringName = &""


## Captures the immutable action definition and its resolved reaction strength.
func _init(initial_action: ElementalAction = null, initial_strength: float = 0.0, initial_rule: StringName = &"") -> void:
	action = initial_action
	strength = initial_strength
	rule_id = initial_rule
