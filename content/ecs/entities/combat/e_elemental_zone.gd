## Generic spatial elemental zone Entity. Area3D overlap is authoritative for contained targets.
@tool
extends Entity
class_name E_ElementalZone


## Runtime zone components are attached by ElementalWorldActions because they depend on the spawned profile.
func define_components() -> Array:
	return []
