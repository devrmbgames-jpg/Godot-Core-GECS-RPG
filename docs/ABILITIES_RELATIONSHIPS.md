# Abilities и Relationships

## Ability Definition vs Instance

`AbilityDefinition : Resource` хранит неизменяемые design data: damage scale, base mana cost, base cooldown, cast work, range и semantic presentation action.

AbilityInstance становится Entity только если нужен runtime state: cooldown, charges, upgrade level, temporary ability-specific modifiers.

### Важная адаптация под GECS v8

Нельзя бездумно делать exact pair `Player --HasAbility--> unique AbilityEntity`: exact Entity target входит в archetype signature, поэтому каждый уникальный loadout способен создать новый archetype.

В ядре используется низкокардинальная форма:

```text
Player -- R_HasAbility(slot=primary, ability=<runtime instance>) --> E_Ability Script
```

Конкретная instance лежит в relation data, а relationship target — стабильный Script `E_Ability`. Ability Entity хранит владельца в обычном `C_EntityOwner`, потому что owner reference высококардинальна и не обязана быть структурным query key.

## Cast representation

Не каждый cast должен быть Entity.

- Мгновенный request: запись semantic slot в `C_AbilityQueue`.
- Длительный cast, когда actor может иметь только один активный cast: `C_Casting` на actor.
- Отдельная Cast Entity: только если cast имеет независимую identity/lifecycle (несколько concurrent casts, channel phases, replication, independent target tracking).

Это уменьшает Node allocation и structural churn.

## Ability pipeline

```text
ControllerIntent
 -> C_AbilityQueue
 -> S_AbilityActivate
 -> validation (dead/cooldown/mana)
 -> optional C_Casting
 -> AbilityResolver
 -> melee hit OR projectile
 -> damage request
 -> O_Damage
 -> C_Health
```

`C_AbilityQueue` является маленькой persistent queue в actor component, поэтому каждый клик не создаёт временную Entity.

## Timing stats

Attack/Shoot используют `C_AttackSpeed`, spell cast — `C_CastSpeed`. `C_Casting.remaining_work` хранит логическую работу и уменьшается так:

```text
remaining_work -= delta * speed.value
```

Поэтому haste, полученный в середине cast, немедленно влияет на оставшееся время без переписывания таймера.

Cooldown аналогично хранит logical work:

```text
C_Cooldown.remaining -= delta * owner.C_CooldownRecovery.value
```

## Mana cost

```text
actual_cost = AbilityDefinition.base_mana_cost * actor.C_ManaCostMultiplier.value
```

Definition не мутируется временными эффектами.

## Damage

Ability damage на первом уровне ядра:

```text
raw = definition.flat_damage + actor.C_Damage.value * definition.damage_scale
```

Затем `O_Damage` применяет armor mitigation и меняет `C_Health.current`. Damage — мгновенный request/event, а не Entity. Если позже появится сложный многофазный damage pipeline (conversion/reflect/block/procs), request можно расширить или сделать отдельной transient simulation сущностью.

## Projectile links

Projectile содержит `source`, `ability` и definition как обычные component references. Это намеренно: projectile высокочастотный и transient, поэтому unique relationship targets дали бы лишний archetype churn.

## Presentation

Gameplay публикует semantic `presentation_action` event. Он не знает конкретный `AnimationPlayer`, model или VFX node. Rig adapter будет добавлен отдельным этапом.
