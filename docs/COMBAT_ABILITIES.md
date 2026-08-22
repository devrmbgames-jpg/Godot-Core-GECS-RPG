# Combat и базовые Abilities

Ядро содержит три примера, собранные одним pipeline:

- **Attack** — melee ray delivery, AttackSpeed timing.
- **Shoot** — projectile delivery, AttackSpeed timing.
- **Fireball** — projectile delivery, CastSpeed timing и mana cost.

Они отличаются конфигурацией `AbilityDefinition`, а не отдельными manager'ами.

## Delivery

`AbilityDefinition.Delivery` пока содержит `MELEE` и `PROJECTILE`. Это механика доставки, а не ID конкретной ability. Новые мечи/заклинания могут переиспользовать delivery без изменения центрального switch по сотням ability IDs.

## Request queue

`S_AbilityIntent` переводит controller flags в semantic slots `primary`, `secondary`, `skill_1`. `S_AbilityActivate` находит `R_HasAbility` для слота и валидирует runtime instance.

## Projectile

Projectile — Node3D Entity с `C_Projectile`. Фактическая позиция принадлежит Node3D; ECS не дублирует `C_Position`. `S_Projectile` делает swept ray между предыдущей и следующей точкой, чтобы быстрый projectile не зависел от Area overlap одного physics tick.

## Death

`O_Damage` добавляет `C_Dead` при HP <= 0. На следующих этапах death lifecycle получит отдельные presentation/loot/cleanup systems; damage observer уже не наносит повторный damage dead entity.
