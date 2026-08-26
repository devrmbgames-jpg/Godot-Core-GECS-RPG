## Базовый физический RigidBody3D Entity с force-based locomotion motor.
@tool
extends Entity
class_name E_RigidCharacter


func define_components() -> Array:
	return [
		C_IsRigid.new(), C_AIController.new(), C_AIChase.new(), C_AIInteractionGoal.new(), C_ControllerIntent.new(),
		C_InteractionSensor.new(), C_CombatState.new(),
		C_MoveSpeed.new(), C_Acceleration.new(), C_Deceleration.new(), C_TurnSpeed.new(), C_InteractionRange.new(),
		C_Health.new(), C_MaxHealth.new(), C_Mana.new(), C_MaxMana.new(),
		C_Damage.new(), C_Armor.new(), C_AttackSpeed.new(), C_CastSpeed.new(),
		C_CooldownRecovery.new(), C_ManaCostMultiplier.new(),
		C_AbilityQueue.new(), C_Casting.new(), C_CombatTarget.new(), C_Inventory.new(), C_Team.new(), C_StatsDirty.new(),
	]
