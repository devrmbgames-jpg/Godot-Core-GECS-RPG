## Generic visible projectile Entity. Node3D transform является position authority.
@tool
extends Entity
class_name E_Projectile


## Gives projectiles the same optional no-Health reaction subject contract as surfaces and zones.
func define_components() -> Array:
	return [
		C_ElementalState.new(),
		C_DamageResistances.new(ElementalIds.TARGET_CONSTRUCT),
		C_StatusImmunities.new(),
		C_ReactiveMaterials.new(),
	]
