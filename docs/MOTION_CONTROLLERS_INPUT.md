# Motion, Controller и Input

## Pipeline

```text
Input/AI source
    -> C_ControllerIntent
    -> S_Motion / S_Rotation
    -> Godot physics body
```

Player и AI отличаются только источником intent. Motion не знает, кто принял решение.

## Physical authority

Для CharacterBody3D и RigidBody3D фактическая velocity остаётся в Godot body. ECS не содержит зеркальную `C_Velocity`.

Компоненты `C_MoveSpeed`, `C_Acceleration`, `C_Deceleration`, `C_TurnSpeed`, `C_Gravity` являются параметрами, а `C_MotorState.controlled_velocity` — только управляемая часть horizontal motion, не копия полной физической velocity.

## External motion

CharacterBody3D не является динамическим rigid body, поэтому внешние импульсы моделируются отдельно через `C_ExternalMotion`. Motor складывает controlled velocity и external contribution. Контакты с RigidBody3D передают часть relative contact velocity в external motion.

Это позволяет ящикам, knockback и другим источникам временно смещать персонажа, не переписывая его movement input.

Для физически полноценного персонажа используется RigidBody3D motor: `S_Motion` прикладывает force к target velocity вместо прямой записи `linear_velocity`. Поэтому collision impulses и силы Jolt остаются частью simulation.

## Configurable input

`InputProfile : Resource` содержит semantic InputMap action names. `C_InputPlayer` ссылается на profile. Переназначение клавиш выполняется через Godot InputMap; gameplay использует только semantic actions.

`R_HasAbility.slot` также является semantic slot (`primary`, `secondary`, `skill_1`), а не клавишей. Input/controller слой позже преобразует action intent в ability request.

## System order

Рекомендуемый physics порядок:

1. Attributes — resolved stats.
2. Input/AI — обновить intent.
3. Motion — вычислить motor velocity/forces и facing.
4. Physics — gravity, `move_and_slide`, collision-to-external impulse.

External impulse, полученный после collision, используется следующим physics tick; это предсказуемая однокадровая staging boundary.
