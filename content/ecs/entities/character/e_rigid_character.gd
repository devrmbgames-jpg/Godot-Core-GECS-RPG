## Базовый физический RigidBody3D Entity с force-based locomotion motor.
##
## Подходит для actors, которым требуется настоящее влияние Jolt forces/contacts.
@tool
extends Entity
class_name E_RigidCharacter


func define_components() -> Array:
	return [
		C_IsRigid.new(),
		C_AIController.new(),
		C_ControllerIntent.new(),
		C_MoveSpeed.new(),
		C_Acceleration.new(),
		C_Deceleration.new(),
		C_TurnSpeed.new(),
		C_StatsDirty.new(),
	]
