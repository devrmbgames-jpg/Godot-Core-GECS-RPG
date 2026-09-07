## Stateless global combat rules. More complex faction/reputation rules can replace these APIs.
extends RefCounted
class_name CombatRules

static var friendly_fire: bool = false


## Проверяет, считаются ли две живые combat-enabled Entity противниками для awareness/AI.
## Neutral или Entity без C_Team не считаются enemies этим базовым правилом.
static func are_enemies(source: Entity, target: Entity) -> bool:
	if source == null or target == null or source == target or target.has_component(C_Dead):
		return false
	var source_team: C_Team = source.get_component(C_Team) as C_Team
	var target_team: C_Team = target.get_component(C_Team) as C_Team
	if source_team == null or target_team == null:
		return false
	if not source_team.combat_enabled or not target_team.combat_enabled:
		return false
	if source_team.team_id == &"neutral" or target_team.team_id == &"neutral":
		return false
	return source_team.team_id != target_team.team_id


## Проверяет право source нанести damage target с учётом death, combat_enabled и friendly_fire.
## Source без C_Team разрешён как environmental/system damage; neutral также damageable.
static func can_damage(source: Entity, target: Entity) -> bool:
	if target == null or target.has_component(C_Dead):
		return false
	var target_team: C_Team = target.get_component(C_Team) as C_Team
	if target_team != null and not target_team.combat_enabled:
		return false
	if source == null:
		return true
	var source_team: C_Team = source.get_component(C_Team) as C_Team
	if source_team != null and not source_team.combat_enabled:
		return false
	if friendly_fire:
		return true
	if source_team == null or target_team == null:
		return true
	if source_team.team_id == &"neutral" or target_team.team_id == &"neutral":
		return true
	return source_team.team_id != target_team.team_id


## Allows a deliberate or affinity-derived heal, including self/allied healing, but never revives a dead target.
## This API must only authorize healing or explicitly friendly status requests, never positive harmful damage.
static func can_heal(source: Entity, target: Entity) -> bool:
	if target == null or not is_instance_valid(target) or target.has_component(C_Dead):
		return false
	if source != null and (not is_instance_valid(source) or source.has_component(C_Dead)):
		return false
	return true
