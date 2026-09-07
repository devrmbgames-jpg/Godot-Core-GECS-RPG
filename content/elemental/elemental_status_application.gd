## Design-time or request-local instruction to add a fixed amount of one status independently of HP damage.
extends Resource
class_name ElementalStatusApplication

@export var status_id: StringName = &""
@export var amount: float = 0.0


## Creates a reusable status application; amount is gauge strength, not damage.
func _init(initial_status: StringName = &"", initial_amount: float = 0.0) -> void:
	status_id = initial_status
	amount = initial_amount
