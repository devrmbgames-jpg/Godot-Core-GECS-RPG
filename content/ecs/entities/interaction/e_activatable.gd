## Generic static interactable Entity для doors/levers/chests demo/prototypes.
@tool
extends Entity
class_name E_Activatable


func define_components() -> Array:
	return [C_Interactable.new(), C_Activatable.new()]
