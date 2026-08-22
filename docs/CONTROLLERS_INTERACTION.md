# Controllers, AI и Interaction

## Controller boundary

Player и AI не двигают actor напрямую. Оба производят `C_ControllerIntent`:

```text
Player InputMap -> S_InputPlayer ----┐
                                     ├-> C_ControllerIntent -> Motion/Ability/Interact
AI behavior -> C_AIController -------┘
```

`S_AIChase` — минимальный пример behavior/steering. Он записывает desired direction и one-shot attack request в `C_AIController`; `S_AIController` преобразует это в общий intent.

## AI Chase

`C_AIChase` содержит target, stop distance и attack distance. System также обновляет `C_CombatTarget`, поэтому Ability pipeline получает ту же target-модель, что и player targeting.

Это не финальный behavior tree. Более сложный Utility AI/BT/GOAP должен заканчиваться тем же `C_AIController`, поэтому locomotion/combat systems не меняются.

## Teams

`C_Team` и `CombatRules` дают минимальную friendly-fire boundary. Это необходимо уже на уровне core: иначе projectile/effect pipeline не может отличить ally от enemy.

## Interaction

```text
ControllerIntent.interact_pressed
 -> S_InteractionIntent
 -> physics ray
 -> InteractionService request
 -> O_Interaction validation
 -> interaction_activated event
 -> O_Activatable / door / chest / dialogue observer
```

`C_Interactable` хранит prompt, enabled и максимальную дистанцию объекта. Actor имеет модифицируемый `C_InteractionRange`.

`O_Activatable` является минимальным примером реакции: target с `C_Activatable` переключает состояние и публикует `activation_changed`. Реальная дверь может слушать это событие и запускать animation/physics transition.

Interaction не знает, кто actor: тот же request может послать AI или script.
