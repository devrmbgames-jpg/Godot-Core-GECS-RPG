## Stateless API изменения C_CombatState без manager-owned state.
extends RefCounted
class_name CombatStateService


## Продлевает combat state actor; отрицательная duration использует linger_duration компонента.
## Dead Entity и actor без C_CombatState безопасно игнорируются.
static func refresh(actor: Entity, duration: float = -1.0) -> void:
	if actor == null or actor.has_component(C_Dead):
		return
	var state: C_CombatState = actor.get_component(C_CombatState) as C_CombatState
	if state != null:
		state.refresh(duration)
