## Immutable design-time описание gameplay effect.
extends Resource
class_name EffectDefinition

enum StackPolicy { REFRESH, STACK, REPLACE, INDEPENDENT }

@export var id: StringName = &"effect"
@export var display_name: String = "Effect"
@export var duration: float = 0.0
@export var tick_interval: float = 1.0
@export_range(1, 999, 1) var max_stacks: int = 1
@export var stack_policy: StackPolicy = StackPolicy.REFRESH

@export_group("Instant / Periodic")
@export var instant_heal: float = 0.0
@export var damage_per_tick: float = 0.0
@export var heal_per_tick: float = 0.0

@export_group("Attributes")
@export var stat_modifiers: Array[StatModifierDefinition] = []

@export_group("Presentation")
@export var presentation_action: StringName = &"effect"
