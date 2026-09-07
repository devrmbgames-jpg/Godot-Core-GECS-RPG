## Stable prototype IDs for elemental data and integration code.
##
## Resolver logic treats IDs as open StringName values; these constants are conveniences,
## not a closed enum, so CSV can introduce new damage/status/material IDs.
extends RefCounted
class_name ElementalIds

const DAMAGE_PHYSICAL: StringName = &"physical"
const DAMAGE_FIRE: StringName = &"fire"
const DAMAGE_ICE: StringName = &"ice"
const DAMAGE_ELECTRIC: StringName = &"electric"
const DAMAGE_POSITIVE: StringName = &"positive"
const DAMAGE_NEGATIVE: StringName = &"negative"
const DAMAGE_POISON: StringName = &"poison"
const DAMAGE_ACID: StringName = &"acid"

const STATUS_NONE: StringName = &""
const STATUS_BURNING: StringName = &"burning"
const STATUS_COLD: StringName = &"cold"
const STATUS_FROZEN: StringName = &"frozen"
const STATUS_WET: StringName = &"wet"
const STATUS_ELECTRIFIED: StringName = &"electrified"
const STATUS_POISONED: StringName = &"poisoned"

const TARGET_LIVING: StringName = &"living"
const TARGET_CONSTRUCT: StringName = &"construct"
const TARGET_UNDEAD: StringName = &"undead"

const MATERIAL_WATER: StringName = &"water"
const MATERIAL_EARTH: StringName = &"earth"
const MATERIAL_POISON: StringName = &"poison_material"

const ENTITY_WET_MIST: StringName = &"wet_mist_zone"
const ENTITY_POISON_CLOUD: StringName = &"poison_cloud"
const SURFACE_ELECTRIFIED_WATER: StringName = &"electrified_water"
const SURFACE_LAVA: StringName = &"lava"
