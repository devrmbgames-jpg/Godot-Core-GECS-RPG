## Базовый third-person CharacterBody3D Entity.
##
## Actual transform/velocity принадлежат CharacterBody3D. GECS components содержат
## controller intent, resolved locomotion stats и отдельные gameplay resources.
@tool
extends Entity
class_name E_KinematicCharacter


func define_components() -> Array:
	return [
		C_IsCharacter.new(),
		C_InputPlayer.new(),
		C_ControllerIntent.new(),
		C_MotorState.new(),
		C_ExternalMotion.new(),
		C_MoveSpeed.new(),
		C_Acceleration.new(),
		C_Deceleration.new(),
		C_TurnSpeed.new(),
		C_Gravity.new(),
		C_StatsDirty.new(),
	]
