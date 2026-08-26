## Runtime selection state для Area3D-based interaction detection.
##
## [member area_path] указывает на Area3D child actor-а. Сам компонент не делает
## physics queries: Area3D поддерживает overlap set внутри physics engine.
extends Component
class_name C_InteractionSensor

@export var area_path: NodePath = ^"InteractionSensor"

## Единственная цель, с которой actor взаимодействует при следующем interact intent.
var selected_target: Entity
