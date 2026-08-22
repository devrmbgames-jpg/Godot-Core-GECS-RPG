# Attributes и modifiers

## Цель

Consumer systems не должны делать `effects.calculate(...)` и не должны обращаться к единому `C_Attribute`.

Каждый важный stat является отдельным типизированным component:

```text
C_MoveSpeed      base_value=6   value=8.4
C_Armor          base_value=10  value=25
C_AttackSpeed    base_value=1   value=1.3
```

`value` — закешированный resolved result, который можно безопасно читать в hot path.

## Формула

Базовая формула проекта:

```text
(base + Σadded) * (1 + Σincreased) * Πmore
```

`MORE` хранит готовый множитель: `1.20` = 20% more, `0.80` = 20% less.

## R_ModifiesStat

Modifier source является Entity (equipment/effect/passive) и создаёт relationship к владельцу stat:

```text
Sword -- R_ModifiesStat(C_Damage, ADDED, +10) --> Player
Haste -- R_ModifiesStat(C_AttackSpeed, INCREASED, +0.25) --> Player
```

Данные modifier принадлежат связи, а не Player и не Sword.

`R_ModifiesStat` считается структурно immutable. Если modifier изменился, предпочтительно удалить старую relationship и добавить новую. Это также гарантирует корректный dirty-event.

## Dirty rebuild

При добавлении/удалении `R_ModifiesStat` Observer помечает target через `C_StatsDirty`.

`S_StatRebuild` обрабатывает только dirty entities, собирает modifiers и записывает готовые `.value`. Затем marker удаляется.

Так MovementSystem читает только:

```gdscript
var speed := entity.get_component(C_MoveSpeed) as C_MoveSpeed
# speed.value уже готов
```

## Runtime resources

Current HP и MaxHealth — разные концепции:

```text
C_MaxHealth.value = 150
C_Health.current  = 83
```

Аналогично `C_Mana.current` отделён от `C_MaxMana.value`.

## Ability costs

`AbilityDefinition.base_mana_cost` нельзя временно мутировать. Общий modifier персонажа хранится в `C_ManaCostMultiplier.value`:

```text
actual_cost = definition.base_mana_cost * actor.C_ManaCostMultiplier.value
```

Специфический modifier конкретной ability при необходимости добавляется на AbilityInstance отдельным stat/component и умножается вторым уровнем.

## Cooldown recovery

Haste не переписывает remaining cooldown всех ability. Храним:

```text
Ability.C_Cooldown.remaining = logical work
Player.C_CooldownRecovery.value = clock rate
```

Tick:

```text
remaining -= delta * cooldown_recovery.value
```

После исчезновения Haste достаточно изменить один resolved stat владельца; все активные cooldown продолжают работу с новой скоростью.
