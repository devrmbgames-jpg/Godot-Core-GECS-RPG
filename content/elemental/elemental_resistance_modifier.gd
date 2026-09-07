## Immutable resistance modifier; category determines strongest-positive/negative stacking.
extends Resource
class_name ElementalResistanceModifier

@export var category: StringName = &"effect"
@export var source_id: StringName = &""
@export var damage_type: StringName = &"PHYSICAL"
@export var amount: int = 0


## Creates a source-addressable modifier. A source replaces its previous value for a channel.
func _init(initial_category: StringName = &"effect", initial_source: StringName = &"", initial_type: StringName = &"PHYSICAL", initial_amount: int = 0) -> void:
	category = initial_category
	source_id = initial_source
	damage_type = initial_type
	amount = initial_amount
