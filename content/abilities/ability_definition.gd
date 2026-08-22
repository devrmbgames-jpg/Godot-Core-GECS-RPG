## Immutable design-time описание ability.
##
## Runtime cooldown/cast/owner не должны записываться сюда. Один Resource может
## безопасно использоваться многими Ability Entity instances.
extends Resource
class_name AbilityDefinition

enum Delivery {
	MELEE,
	PROJECTILE,
}

enum Timing {
	ATTACK,
	CAST,
	INSTANT,
}

@export var id: StringName = &"ability"
@export var display_name: String = "Ability"
@export var delivery: Delivery = Delivery.MELEE
@export var timing: Timing = Timing.ATTACK

@export_group("Costs and Timing")
@export var base_mana_cost: float = 0.0
@export var base_cooldown: float = 0.0
## Логическая длительность windup. Реальное время зависит от AttackSpeed/CastSpeed.
@export var base_cast_work: float = 0.0

@export_group("Damage")
@export var flat_damage: float = 0.0
@export var damage_scale: float = 1.0
@export var range: float = 2.0

@export_group("Projectile")
@export var projectile_speed: float = 18.0
@export var projectile_lifetime: float = 4.0

@export_group("Presentation")
## Semantic action id для CharacterRig, не имя конкретной AnimationPlayer animation.
@export var presentation_action: StringName = &"ability"
