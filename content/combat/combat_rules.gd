## Stateless глобальные базовые combat rules.
## Более сложные faction/reputation rules могут заменить реализацию, сохранив API.
extends RefCounted
class_name CombatRules

static var friendly_fire: bool = false


static func can_damage(source: Entity, target: Entity) -> bool:
	if target == null or target.has_component(C_Dead):
		return false
	if source == null or friendly_fire:
		return true
	var source_team := source.get_component(C_Team) as C_Team
	var target_team := target.get_component(C_Team) as C_Team
	if source_team == null or target_team == null:
		return true
	if source_team.team_id == &"neutral" or target_team.team_id == &"neutral":
		return true
	return source_team.team_id != target_team.team_id
