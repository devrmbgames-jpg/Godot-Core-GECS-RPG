## Runtime API для настройки Godot InputMap без зависимости gameplay systems от клавиш.
extends RefCounted
class_name InputBindingService


## Полностью заменяет bindings semantic action одним InputEvent.
static func rebind(action: StringName, event: InputEvent, deadzone: float = 0.2) -> void:
	_ensure_action(action, deadzone)
	InputMap.action_erase_events(action)
	if event != null:
		InputMap.action_add_event(action, event)


## Добавляет альтернативный binding semantic action.
static func add_binding(action: StringName, event: InputEvent, deadzone: float = 0.2) -> void:
	if event == null:
		return
	_ensure_action(action, deadzone)
	InputMap.action_add_event(action, event)


## Удаляет все bindings, оставляя semantic action зарегистрированным.
static func clear_bindings(action: StringName) -> void:
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)


## Гарантирует наличие всех semantic actions profile в InputMap.
static func ensure_profile(profile: InputProfile) -> void:
	if profile == null:
		return
	for action in [
		profile.move_left, profile.move_right, profile.move_forward, profile.move_backward,
		profile.primary_action, profile.secondary_action, profile.skill_1_action, profile.interact,
	]:
		_ensure_action(action, 0.2)


## Создаёт InputMap action при отсутствии или обновляет deadzone существующего action.
static func _ensure_action(action: StringName, deadzone: float) -> void:
	if action == &"":
		return
	if not InputMap.has_action(action):
		InputMap.add_action(action, deadzone)
	else:
		InputMap.action_set_deadzone(action, deadzone)
