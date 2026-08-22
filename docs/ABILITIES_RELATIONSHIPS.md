# Abilities и Relationships

## Ability Definition vs Instance

`AbilityDefinition : Resource` хранит неизменяемые design data: base damage, base mana cost, base cooldown, cast time, animation semantic id, список effect definitions.

AbilityInstance становится Entity только если нужен runtime state: cooldown, charges, upgrade level, temporary ability-specific modifiers.

```text
Player --R_HasAbility(slot=primary)--> FireballAbility
FireballAbility --R_OwnedBy----------> Player
```

Двунаправленная семантика здесь намеренная: `R_HasAbility` удобен для actor-centric queries/UI, `R_OwnedBy` — для systems, обрабатывающих ability entities. Если profiling покажет, что одна сторона не нужна, её можно убрать.

## Cast representation

Не каждый cast должен быть Entity.

- Мгновенный `Attack/Shoot/Fireball` request: action/request/event, который validation/resolve выполняет в одну logical operation.
- Длительный cast, когда actor может иметь только один активный cast: `C_Casting` на actor/ability.
- Отдельная Cast Entity: только если cast имеет независимую identity и lifecycle (interrupt, channel, phases, replication, несколько независимых systems).

Это уменьшает Node allocation и structural churn.

## Effect representation

Простой постоянный modifier может быть только relationship от source к actor.

Сложный эффект `Poison/Burning/Regen` становится Effect Entity:

```text
PoisonEffect
  C_Duration
  C_Tick
  R_AppliedTo -> Victim
  R_Source    -> Attacker
  R_ModifiesStat -> Victim   # если одновременно замедляет
```

## Ability не вызывает presentation напрямую

Gameplay не должен знать конкретный `AnimationPlayer`, VFX node или audio bus. Он создаёт semantic presentation request/event (`attack_light`, `cast_fireball`, `hit_react`). CharacterRig adapter переводит semantic id в конкретное состояние AnimationTree/AnimationPlayer готовой модели.

## Примеры

### Attack

```text
Controller intent -> Attack request -> validation
-> attack timing (AttackSpeed)
-> hit query -> Damage request -> Health
```

### Shoot

```text
Shoot request -> validation/cost/cooldown
-> projectile entity -> physics/hit
-> Damage request
```

### Fireball

```text
Cast request -> validation (ManaCost, cooldown)
-> optional cast phase (CastSpeed)
-> projectile/effect spawn
-> Damage + Burning
```

Ability logic создаёт gameplay data. Animation, VFX и sound наблюдают semantic events и не являются зависимостями Ability system.
