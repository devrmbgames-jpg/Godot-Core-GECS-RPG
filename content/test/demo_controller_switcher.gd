## Demo UI: циклически передаёт локальный PlayerController между уже размещёнными Entity.
##
## Никаких Entity здесь не создаётся и не позиционируется: candidates задаются NodePath в .tscn.
extends Control
class_name DemoControllerSwitcher

signal controlled_entity_changed(entity: Entity)

@export var candidates: Array[NodePath] = []
@export var switch_button_path: NodePath = ^"Panel/VBox/SwitchButton"
@export var enemies_button_path: NodePath = ^"Panel/VBox/EnemiesButton"
@export var status_label_path: NodePath = ^"Panel/VBox/Status"
@export var player_team: StringName = &"player"
@export var ai_team: StringName = &"enemy"

var selected_index: int = 0
var current_actor: Entity
var enemies_enabled: bool = true
var _button: Button
var _enemies_button: Button
var _status: Label


func _ready() -> void:
	_button = get_node_or_null(switch_button_path) as Button
	_enemies_button = get_node_or_null(enemies_button_path) as Button
	_status = get_node_or_null(status_label_path) as Label
	if _button != null:
		_button.pressed.connect(switch_next)
	if _enemies_button != null:
		_enemies_button.pressed.connect(toggle_enemies)
		_update_enemies_button()
	call_deferred("_initialize_selection")


func _process(_delta: float) -> void:
	_update_status()


## Выбирает следующую заранее размещённую Entity.
func switch_next() -> void:
	if candidates.is_empty():
		return
	selected_index = (selected_index + 1) % candidates.size()
	_activate_index(selected_index)


## Demo-only switch: AI enemies остаются размещены, но прекращают combat/AI activity.
func toggle_enemies() -> void:
	enemies_enabled = not enemies_enabled
	for path in candidates:
		var actor := get_node_or_null(path) as Entity
		if actor == null or actor == current_actor:
			continue
		_set_enemy_enabled(actor, enemies_enabled)
	_update_enemies_button()


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
	InteractionSelectionService.set_target(actor, null)
	var intent := actor.get_component(C_ControllerIntent) as C_ControllerIntent
	if intent != null:
		_clear_intent(intent)
	var combat_target := actor.get_component(C_CombatTarget) as C_CombatTarget
	if enabled and combat_target != null:
		combat_target.target = null
	var team := actor.get_component(C_Team) as C_Team
	if team != null:
		team.team_id = player_team if enabled else ai_team
		team.combat_enabled = true if enabled else enemies_enabled
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
		_set_enemy_enabled(actor, enemies_enabled)


func _set_enemy_enabled(actor: Entity, enabled: bool) -> void:
	var controller := actor.get_component(C_AIController) as C_AIController
	if controller != null:
		controller.enabled = enabled
		if not enabled:
			controller.desired_move_direction = Vector3.ZERO
			controller.desired_facing_direction = Vector3.ZERO
	var team := actor.get_component(C_Team) as C_Team
	if team != null and actor != current_actor:
		team.combat_enabled = enabled
	var intent := actor.get_component(C_ControllerIntent) as C_ControllerIntent
	if not enabled and intent != null:
		_clear_intent(intent)
	var combat_state := actor.get_component(C_CombatState) as C_CombatState
	if not enabled and combat_state != null:
		combat_state.clear()


func _clear_intent(intent: C_ControllerIntent) -> void:
	intent.move_direction = Vector3.ZERO
	intent.facing_direction = Vector3.ZERO
	intent.aim_direction = Vector3.ZERO
	intent.primary_pressed = false
	intent.secondary_pressed = false
	intent.skill_1_pressed = false
	intent.interact_pressed = false


func _refresh_ai_targets() -> void:
	for path in candidates:
		var actor := get_node_or_null(path) as Entity
		if actor == null or actor == current_actor:
			continue
		var chase := actor.get_component(C_AIChase) as C_AIChase
		if chase != null:
			chase.target = current_actor


func _update_enemies_button() -> void:
	if _enemies_button != null:
		_enemies_button.text = "Enemies: %s" % ("ON" if enemies_enabled else "OFF")


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
	var combat := current_actor.get_component(C_CombatState) as C_CombatState
	var interaction := current_actor.get_component(C_InteractionSensor) as C_InteractionSensor
	var equipped := EquipmentRuntime.find_equipped(current_actor, &"main_hand")
	var item_name := "None"
	if equipped != null:
		var item := equipped.get_component(C_Item) as C_Item
		if item != null and item.definition != null:
			item_name = item.definition.display_name
	var interaction_name := "None"
	if interaction != null and interaction.selected_target != null and is_instance_valid(interaction.selected_target):
		interaction_name = interaction.selected_target.name
	var combat_label := "ON" if combat != null and combat.active else "OFF"
	var nearby: int = combat.nearby_enemy_count if combat != null else 0
	_status.text = "%s\nHP %.0f/%.0f  Mana %.0f/%.0f\nMove %.1f  Damage %.1f  AttackSpeed %.2f\nCombat: %s  Nearby enemies: %d\nInteract target: %s\nMain hand: %s" % [
		current_actor.name,
		health.current if health != null else 0.0,
		max_health.value if max_health != null else 0.0,
		mana.current if mana != null else 0.0,
		max_mana.value if max_mana != null else 0.0,
		speed.value if speed != null else 0.0,
		damage.value if damage != null else 0.0,
		attack_speed.value if attack_speed != null else 0.0,
		combat_label,
		nearby,
		interaction_name,
		item_name,
	]
