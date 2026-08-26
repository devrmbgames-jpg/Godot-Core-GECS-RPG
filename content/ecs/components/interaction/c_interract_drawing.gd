## Опциональная presentation-настройка подсветки выбранного interactable.
##
## Имя класса сохраняет написание `Interract`, использованное в gameplay API проекта.
## Если компонента нет, selection работает как обычно, но объект не подсвечивается.
extends Component
class_name C_InterractDrawing

@export var mesh_path: NodePath = ^"MeshInstance3D"
@export var highlight_color: Color = Color(1.0, 0.78, 0.18, 0.28)
@export_range(0.0, 8.0, 0.1) var emission_energy: float = 2.0

## Runtime presentation cache. Не является gameplay authority.
var highlighted: bool = false
var original_overlay: Material
var highlight_material: StandardMaterial3D
