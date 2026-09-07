## Generic spatial elemental zone Entity. Area3D overlap is authoritative for contained targets.
@tool
extends Entity
class_name E_ElementalZone


## Provides persistent elemental state; C_ElementalZone is attached by the spawn adapter with a profile.
func define_components() -> Array:
	return [C_ElementalState.new()]
