# Input Context

- `input_profile.gd` — semantic action names, не runtime input state.
- `input_binding_service.gd` — InputMap rebind/add/clear/ensure helper.
- `ecs/systems/input/s_input_player.gd` — device snapshot into `C_InputState`.
- `ecs/systems/controller/s_player_controller.gd` — camera-relative movement + cursor world aim into `C_ControllerIntent`.

Gameplay systems не должны читать `Input` напрямую. Новое управление сначала добавляется в profile/state/controller boundary.