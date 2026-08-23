# Motion, Controller и Input

## Pipeline

```text
Godot InputMap -> C_InputState -> S_PlayerController --┐
                                                       ├-> C_ControllerIntent -> Motion / Ability / Interact
AI behavior -> C_AIController -> S_AIController -------┘
```

Input и Controller разделены намеренно: device bindings не знают camera/world-space, а Controller не знает физические клавиши.

## Configurable input

`InputProfile : Resource` хранит semantic InputMap action names. `C_InputPlayer` выбирает profile. `InputBindingService` позволяет runtime add/rebind/clear bindings; сохранение пользовательских preferences является boundary UI/settings слоя.

`R_HasAbility.slot` — semantic slot (`primary`, `secondary`, `skill_1`), не физическая клавиша.

## Physical authority

Для CharacterBody3D и RigidBody3D фактическая velocity остаётся в Godot body. ECS не содержит зеркальную `C_Velocity`.

`C_MoveSpeed`, `C_Acceleration`, `C_Deceleration`, `C_TurnSpeed`, `C_Gravity` — параметры. `C_MotorState.controlled_velocity` — только управляемая horizontal contribution, не копия actual velocity.

## External motion

CharacterBody3D не является динамическим rigid body, поэтому внешние импульсы моделируются через `C_ExternalMotion`. Motor складывает controlled и external horizontal contributions; vertical external velocity попадает непосредственно в CharacterBody velocity.

Контакты с RigidBody3D передают часть relative contact speed в external contribution. Это приближение для third-person kinematic actor; если нужен полностью физический герой, следует использовать RigidBody3D motor.

RigidBody3D locomotion прикладывает force к target velocity и не перезаписывает `linear_velocity`, поэтому Jolt collision impulses и внешние силы сохраняются.

## System order

1. Attributes — resolved stats.
2. AI — desired behavior.
3. Input — sample device; Player/AI Controller -> common intent.
4. Gameplay — interaction/abilities/effects.
5. Motion — controlled velocity/forces/facing.
6. Physics — gravity, move_and_slide, projectile/contact processing.
7. Presentation — rig reflection.

Modifier, добавленный после Attributes group, применяется к resolved stat на следующем frame. Это предсказуемая staging boundary, а не скрытый immediate recalculation.
