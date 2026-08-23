## Делает Entity доступной для generic Interaction pipeline.
extends Component
class_name C_Interactable

@export var prompt: String = "Interact"
@export var enabled: bool = true
## 0 означает использовать только actor.C_InteractionRange.
@export var max_distance: float = 0.0
@export var presentation_action: StringName = &"interact"
