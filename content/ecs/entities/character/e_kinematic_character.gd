## Базовый third-person CharacterBody3D Entity.
@tool
extends Entity
class_name E_KinematicCharacter


func define_components() -> Array:
	return [
		C_IsCharacter.new(), C_InputPlayer.new(), C_InputState.new(), C_PlayerController.new(), C_ControllerIntent.new(),
		C_InteractionSensor.new(), C_AIInteractionGoal.new(), C_CombatState.new(),
		C_MotorState.new(), C_ExternalMotion.new(),
		C_MoveSpeed.new(), C_Acceleration.new(), C_Deceleration.new(), C_TurnSpeed.new(), C_Gravity.new(), C_InteractionRange.new(),
		C_Health.new(), C_MaxHealth.new(), C_Mana.new(), C_MaxMana.new(),
		C_Damage.new(), C_Armor.new(), C_AttackSpeed.new(), C_CastSpeed.new(),
		C_CooldownRecovery.new(), C_ManaCostMultiplier.new(),
		C_AbilityQueue.new(), C_Casting.new(), C_CombatTarget.new(), C_Inventory.new(), C_Team.new(), C_StatsDirty.new(),
	]
