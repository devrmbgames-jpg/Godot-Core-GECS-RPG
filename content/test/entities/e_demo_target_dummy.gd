## Primitive combat target с Health/Armor/Team для Attack/Shoot/Fireball demo.
@tool
extends Entity
class_name E_DemoTargetDummy

@export var max_health: float = 300.0
@export var armor: float = 10.0


## Возвращает минимальный damageable enemy component set для статической demo target.
func define_components() -> Array:
	return [
		C_Health.new(max_health),
		C_MaxHealth.new(max_health),
		C_Armor.new(armor),
		C_Team.new(&"enemy"),
		C_StatsDirty.new(),
	]


## Обновляет demo Label3D из runtime Health и показывает DEAD после появления C_Dead.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var label := get_node_or_null("Label3D") as Label3D
	var health := get_component(C_Health) as C_Health
	if label == null or health == null:
		return
	label.text = "TARGET DUMMY\nHP %.0f / %.0f" % [health.current, max_health]
	if has_component(C_Dead):
		label.text += "\nDEAD"
