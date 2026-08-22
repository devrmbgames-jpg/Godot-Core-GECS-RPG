## Продвигает cooldown ability по clock rate владельца.
extends System
class_name S_Cooldown


func query() -> QueryBuilder:
	return q.with_all([C_Ability, C_Cooldown, C_EntityOwner]).iterate([C_Cooldown, C_EntityOwner])


func process(_entities: Array[Entity], components: Array, delta: float) -> void:
	var cooldowns: Array = components[0]
	var owners: Array = components[1]
	for index in cooldowns.size():
		var cooldown := cooldowns[index] as C_Cooldown
		if cooldown.remaining <= 0.0:
			continue
		var owner := (owners[index] as C_EntityOwner).owner
		var recovery := owner.get_component(C_CooldownRecovery) as C_CooldownRecovery if owner != null else null
		var rate := recovery.value if recovery != null else 1.0
		cooldown.remaining = maxf(0.0, cooldown.remaining - delta * maxf(rate, 0.0))
