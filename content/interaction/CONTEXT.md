# Interaction Context

## Pipeline

`Area3D InteractionSensor -> C_InteractionSensor -> player/AI selection -> C_ControllerIntent.interact_pressed -> InteractionService -> O_Interaction -> target-specific observer`.

## Entry points

- `interaction_targeting.gd` — Area3D overlap -> Entity candidates and nearest selection.
- `interaction_rules.gd` — enabled/range validation.
- `interaction_selection_service.gd` — selected target state + optional visual update.
- `interaction_service.gd` / `interaction_request.gd` — activation request.
- `interaction_drawing_presenter.gd` — optional highlight for `C_InterractDrawing`.
- `ecs/systems/interaction/s_player_interaction_selection.gd` — nearest valid player target.
- `ecs/systems/interaction/s_ai_interaction_selection.gd` — validates AI-requested goal; does not choose nearest by default.

## Rules

Interaction does not run a raycast when E is pressed. Exactly one selected target is stored per actor. AI decision logic sets `C_AIInteractionGoal.target` when it eventually learns levers/buttons/etc.