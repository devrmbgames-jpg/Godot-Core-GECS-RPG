# Effect System

Effect — отдельная runtime Entity только если у него есть lifetime, ticks, stacks или modifier ownership. Мгновенный Heal не создаёт Entity и проходит через request/event.

## EffectDefinition

Одна definition может комбинировать:

- instant heal;
- periodic damage;
- periodic heal;
- один или несколько stat modifiers;
- duration/tick interval;
- stacking policy.

Поэтому Poison, Burning, Regeneration, Haste и Slow — data configurations одной системы.

## Runtime

```text
Target
  R_HasEffect(effect=<instance>, effect_id=poison) -> E_Effect Script

Effect Entity (add_to_tree=false)
  C_Effect
  C_EffectContext(target/source/ability/stacks)
  C_Duration
  C_EffectTick (если нужен)
```

Как и Ability, exact Effect Entity не используется как relationship target: target — стабильный `E_Effect` Script, instance хранится в relation data.

## Stat modifiers

Effect с modifier создаёт relationships **на target actor**:

```text
Player -- R_ModifiesStat(source=SlowEffect, MORE, 0.6) --> C_MoveSpeed
```

При изменении stack count старые relation instances удаляются и создаются новые с новым amount. `O_StatModifierChanged` автоматически помечает stat dirty.

## Stacking

- `REFRESH` — одна instance, duration обновляется.
- `STACK` — одна instance, увеличивается `stacks` до `max_stacks`, duration обновляется; periodic/stat values умножаются на stacks.
- `REPLACE` — старые instances удаляются, создаётся новая.
- `INDEPENDENT` — каждый application создаёт отдельную instance.

## Tick order

`S_EffectTick` выполняется перед `S_EffectDuration`: последний tick текущего кадра не теряется из-за раннего удаления effect.

## Requests

Effect application и Heal — мгновенные requests через GECS custom events. Это позволяет несколько applications/hits в один frame без создания transient Entity на каждый request.
