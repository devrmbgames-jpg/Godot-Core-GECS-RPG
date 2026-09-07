## Design-time profile for a material, spawned zone or cloud. Spatial scenes are optional presentation data.
extends Resource
class_name ElementalEnvironmentDefinition

@export var id: StringName = &""
@export var material_id: StringName = &""
@export var tags: Array[StringName] = []
@export var scene: PackedScene
@export var radius: float = 2.0
## Zero means a permanent surface; positive duration is used for temporary zones.
@export var duration: float = 0.0
@export var tick_interval: float = 1.0
@export var damage_type: StringName = &"PHYSICAL"
@export var damage_amount: float = 0.0
@export var buildup_scale: float = 1.0
@export var status_applications: Array[ElementalStatusApplication] = []
## Environmental pulses affect every overlap when true, independently of the creator's team.
@export var affects_all: bool = true


## Validates the numeric invariants required by the zone runtime.
func is_valid_definition() -> bool:
	return id != &"" and radius > 0.0 and duration >= 0.0 and tick_interval > 0.0 and damage_amount >= 0.0 and buildup_scale >= 0.0
