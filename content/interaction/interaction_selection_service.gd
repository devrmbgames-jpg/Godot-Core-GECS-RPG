## Единственная точка изменения selected interaction target.
## Local player selection обновляет optional highlight; AI selection — нет.
extends RefCounted
class_name InteractionSelectionService


## Меняет C_InteractionSensor.selected_target и синхронизирует optional highlight local player.
## Повторная установка той же цели является no-op.
static func set_target(actor: Entity, target: Entity) -> void:
	if actor == null:
		return
	var sensor: C_InteractionSensor = actor.get_component(C_InteractionSensor) as C_InteractionSensor
	if sensor == null or sensor.selected_target == target:
		return
	var draws_selection: bool = actor.has_component(C_InputPlayer)
	if draws_selection and sensor.selected_target != null:
		InteractionDrawingPresenter.set_highlight(sensor.selected_target, false)
	sensor.selected_target = target
	if draws_selection and target != null:
		InteractionDrawingPresenter.set_highlight(target, true)
