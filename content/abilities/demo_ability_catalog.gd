## Небольшой каталог definitions для integration demo.
extends RefCounted
class_name DemoAbilityCatalog


## Создаёт melee Attack definition; cadence определяется AttackSpeed, а не cooldown.
static func attack() -> AbilityDefinition:
	var definition := AbilityDefinition.new()
	definition.id = &"attack"; definition.display_name = "Attack"
	definition.delivery = AbilityDefinition.Delivery.MELEE
	definition.timing = AbilityDefinition.Timing.ATTACK
	definition.base_cast_work = 0.28
	# AttackSpeed управляет attack cadence; отдельный cooldown здесь не нужен.
	definition.base_cooldown = 0.0
	definition.damage_scale = 1.0; definition.range = 2.4
	definition.presentation_action = &"attack"
	return definition


## Создаёт быстрый projectile Shoot definition с AttackSpeed timing.
static func shoot() -> AbilityDefinition:
	var definition := AbilityDefinition.new()
	definition.id = &"shoot"; definition.display_name = "Shoot"
	definition.delivery = AbilityDefinition.Delivery.PROJECTILE
	definition.timing = AbilityDefinition.Timing.ATTACK
	definition.base_cast_work = 0.20
	definition.base_cooldown = 0.0
	definition.flat_damage = 5.0; definition.damage_scale = 1.0; definition.range = 30.0
	definition.projectile_speed = 28.0; definition.projectile_lifetime = 3.0
	definition.presentation_action = &"shoot"
	return definition


## Создаёт mana-consuming Fireball definition с CastSpeed timing, cooldown и Burning effect.
static func fireball() -> AbilityDefinition:
	var definition := AbilityDefinition.new()
	definition.id = &"fireball"; definition.display_name = "Fireball"
	definition.delivery = AbilityDefinition.Delivery.PROJECTILE
	definition.timing = AbilityDefinition.Timing.CAST
	definition.base_mana_cost = 20.0
	definition.base_cast_work = 0.65
	definition.base_cooldown = 2.0
	definition.flat_damage = 25.0; definition.damage_scale = 1.25; definition.range = 35.0
	definition.projectile_speed = 20.0; definition.projectile_lifetime = 4.0
	definition.effects = [DemoEffectCatalog.burning()]
	definition.presentation_action = &"cast_fireball"
	return definition
