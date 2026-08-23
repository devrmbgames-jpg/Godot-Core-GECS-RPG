## Demo UI: циклически передаёт локальный PlayerController между уже размещёнными Entity.
##
## Никаких Entity здесь не создаётся и не позиционируется: candidates задаются NodePath в .tscn.
extends Control
class_name DemoControllerSwitcher

signal controlled_entity_changed(entity: Entity)

@export var candidates: Array[NodePath] = []
@export var switch_button_path: NodePath
@export var status_label_path: NodePath
@export var player_team: StringName = &"player"
@export var ai_team: StringName = &"enemy"

var selected_index: int = 0
var current_actor: Entity
var _button: Button
var _status: Label


func _ready() -> void:
	_button = get_node_or_null(switch_button_path) as Button
	_status = get_node_or_null(status_label_path) as Label
	if _button != null:
		_button.pressed.connect(switch_next)
	call_deferred("_initialize_selection")


func _process(_delta: float) -> void:
	_update_status()


## Выбирает следующую заранее размещённую Entity.
func switch_next() -> void:
	if candidates.is_empty():
		return
	selected_index = (selected_index + 1) % candidates.size()
	_activate_index(selected_index)


func _initialize_selection() -> void:
	if candidates.is_empty():
		return
	for index in candidates.size():
		var actor := get_node_or_null(candidates[index]) as Entity
		if actor != null and actor.has_component(C_InputPlayer):
			selected_index = index
			break
	_activate_index(selected_index)


func _activate_index(index: int) -> void:
	if index < 0 or index >= candidates.size():
		return
	var next_actor := get_node_or_null(candidates[index]) as Entity
	if next_actor == null or next_actor.has_component(C_Dead):
		return
	for path in candidates:
		var actor := get_node_or_null(path) as Entity
		if actor == null:
			continue
		_set_local_control(actor, actor == next_actor)
	current_actor = next_actor
	_refresh_ai_targets()
	controlled_entity_changed.emit(current_actor)
	if _button != null:
		_button.text = "Switch Controller (now: %s)" % current_actor.name


func _set_local_control(actor: Entity, enabled: bool) -> void:
	var intent := actor.get_component(C_ControllerIntent) as C_ControllerIntent
	if intent != null:
		intent.move_direction = Vector3.ZERO
		intent.facing_direction = Vector3.ZERO
		intent.primary_pressed = false
		intent.secondary_pressed = false
		intent.skill_1_pressed = false
		intent.interact_pressed = false
	var team := actor.get_component(C_Team) as C_Team
	if team != null:
		team.team_id = player_team if enabled else ai_team
	if enabled:
		if actor.has_component(C_AIController):
			actor.remove_component(C_AIController)
		if not actor.has_component(C_InputPlayer):
			actor.add_component(C_InputPlayer.new())
		if not actor.has_component(C_InputState):
			actor.add_component(C_InputState.new())
		if not actor.has_component(C_PlayerController):
			actor.add_component(C_PlayerController.new())
	else:
		if actor.has_component(C_InputPlayer): actor.remove_component(C_InputPlayer)
		if actor.has_component(C_InputState): actor.remove_component(C_InputState)
		if actor.has_component(C_PlayerController): actor.remove_component(C_PlayerController)
		if actor.has_component(C_AIChase) and not actor.has_component(C_AIController):
			actor.add_component(C_AIController.new())


func _refresh_ai_targets() -> void:
	for path in candidates:
		var actor := get_node_or_null(path) as Entity
		if actor == null or actor == current_actor:
			continue
		var chase := actor.get_component(C_AIChase) as C_AIChase
		if chase != null:
			chase.target = current_actor


func _update_status() -> void:
	if _status == null or current_actor == null or not is_instance_valid(current_actor):
		return
	var health := current_actor.get_component(C_Health) as C_Health
	var max_health := current_actor.get_component(C_MaxHealth) as C_MaxHealth
	var mana := current_actor.get_component(C_Mana) as C_Mana
	var max_mana := current_actor.get_component(C_MaxMana) as C_MaxMana
	var speed := current_actor.get_component(C_MoveSpeed) as C_MoveSpeed
	var damage := current_actor.get_component(C_Damage) as C_Damage
	var attack_speed := current_actor.get_component(C_AttackSpeed) as C_AttackSpeed
	var equipped := EquipmentRuntime.find_equipped(current_actor, &"main_hand")
	var item_name := "None"
	if equipped != null:
		var item := equipped.get_component(C_Item) as C_Item
		if item != null and item.definition != null:
			item_name = item.definition.display_name
	_status.text = "%s\nHP %.0f/%.0f  Mana %.0f/%.0f\nMove %.1f  Damage %.1f  AttackSpeed %.2f\nMain hand: %s" % [
		current_actor.name,
		health.current if health != null else 0.0,
		max_health.value if max_health != null else 0.0,
		mana.current if mana != null else 0.0,
		max_mana.value if max_mana != null else 0.0,
		speed.value if speed != null else 0.0,
		damage.value if damage != null else 0.0,
		attack_speed.value if attack_speed != null else 0.0,
		item_name,
	]
