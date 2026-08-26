# ECS Systems Context

Systems — frame processors, сгруппированные в `test.tscn` по execution group.

## Order-sensitive pipeline

- `attributes/s_stat_rebuild.gd` — dirty stat resolution.
- `combat/s_combat_state.gd` — Area3D enemy awareness + linger.
- `controller/s_ai_chase.gd` — demo AI behavior -> desired controller data.
- `input/s_input_player.gd` — InputMap -> C_InputState.
- `controller/s_player_controller.gd`, `s_ai_controller.gd` — -> C_ControllerIntent.
- `interaction/*selection.gd` — selected interaction target.
- `ability/s_ability_intent.gd` -> activate -> casting/cooldown.
- `effect/*` — periodic runtime.
- `motion/s_motion.gd`, `s_rotation.gd` — controller intent -> motor/forces.
- `physics/s_gravity.gd`, `s_kinematic_character.gd`, combat projectile — Godot physics execution.
- `presentation/s_rig_locomotion.gd` — presentation readback.

## Rule

Новый System должен явно указывать, какие компоненты читает/пишет и в какой group должен выполняться. Если результат нужен System того же frame, порядок должен быть отражён здесь и в playground scene.