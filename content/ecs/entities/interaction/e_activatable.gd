## Generic static interactable Entity для doors/levers/chests demo/prototypes.
@tool
extends Entity
class_name E_Activatable


## Возвращает minimal interactable/toggle state и optional drawing capability для world object.
func define_components() -> Array:
	return [C_Interactable.new(), C_Activatable.new(), C_InterractDrawing.new()]
