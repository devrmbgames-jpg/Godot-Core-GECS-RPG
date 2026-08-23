## Типизированный semantic presentation event.
##
## Gameplay публикует semantic action/phase и только релевантный typed context.
## CharacterRig решает, как именно отобразить событие конкретной моделью/animation set.
extends RefCounted
class_name PresentationActionEvent

var action: StringName = &""
var phase: StringName = &"start"
var ability: Entity
var item: Entity
var item_definition: ItemDefinition
var effect: Entity
var target: Entity


func _init(initial_action: StringName = &"", initial_phase: StringName = &"start") -> void:
	action = initial_action
	phase = initial_phase


static func simple(action: StringName, phase: StringName = &"start") -> PresentationActionEvent:
	return PresentationActionEvent.new(action, phase)


static func for_ability(action: StringName, phase: StringName, ability_entity: Entity) -> PresentationActionEvent:
	var event := PresentationActionEvent.new(action, phase)
	event.ability = ability_entity
	return event


static func for_item(
	action: StringName,
	phase: StringName,
	item_entity: Entity,
	definition: ItemDefinition,
) -> PresentationActionEvent:
	var event := PresentationActionEvent.new(action, phase)
	event.item = item_entity
	event.item_definition = definition
	return event


static func for_effect(action: StringName, phase: StringName, effect_entity: Entity) -> PresentationActionEvent:
	var event := PresentationActionEvent.new(action, phase)
	event.effect = effect_entity
	return event


static func for_target(action: StringName, phase: StringName, target_entity: Entity) -> PresentationActionEvent:
	var event := PresentationActionEvent.new(action, phase)
	event.target = target_entity
	return event
