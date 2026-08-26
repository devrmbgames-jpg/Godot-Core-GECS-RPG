# Combat и базовые Abilities

Ядро содержит три примера, собранные одним pipeline: Attack, Shoot и Fireball. Они отличаются `AbilityDefinition`, а не отдельными manager-классами.

## Cursor aim

Local player хранит screen pointer только в `C_InputState`. `S_PlayerController` проектирует camera ray на горизонтальную плоскость actor-а и записывает typed `aim_world_position/aim_direction` в `C_ControllerIntent`.

При запуске ability player не использует stale `C_CombatTarget`: `S_AbilityActivate` передаёт cursor world position в cast/resolve pipeline. Поэтому melee/projectile направлены к курсору. AI по-прежнему использует `C_CombatTarget`.

## Combat state

`C_CombatState` становится active, если:

- успешно запускается `AbilityDefinition.is_offensive`;
- actor получает `DamageRequest.Kind.DIRECT`;
- `CombatSensor Area3D` видит хотя бы одного живого enemy.

После последнего offensive action/direct hit состояние держится `linger_duration` (по умолчанию 4 секунды). Nearby enemy постоянно обновляет timer. Periodic Poison/Burning damage помечен `DamageRequest.Kind.PERIODIC` и сам по себе linger не продлевает.

В combat state Player Controller постоянно задаёт facing к cursor aim. Motion сравнивает movement с facing и плавно снижает скорость движения назад до `backpedal_speed_multiplier` (по умолчанию 0.75). Стрейф и движение вперёд остаются ближе к полной скорости.

## Projectile

Projectile — Node3D Entity с `C_Projectile`. Фактическая позиция принадлежит Node3D; ECS не дублирует `C_Position`. `S_Projectile` делает swept ray между предыдущей и следующей точкой, чтобы быстрый projectile не зависел от Area overlap одного physics tick.

## Death

`O_Damage` добавляет `C_Dead` при HP <= 0. Dead actor исключается из player/AI control, motion и combat-state processing.
