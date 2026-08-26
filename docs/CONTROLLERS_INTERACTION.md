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

`C_AIChase` содержит target, stop distance и attack distance. System также обновляет `C_CombatTarget`, поэтому Ability pipeline получает entity-target для AI. Player ability targeting не использует этот target: направление приходит от cursor aim.

## Teams

`C_Team` и `CombatRules` дают минимальную friendly-fire/enemy boundary. `combat_enabled` позволяет временно исключить actor из combat без смены team identity — playground использует это для кнопки Enemies ON/OFF.

## Interaction через Area3D

Interaction больше не выполняет постоянные raycasts.

```text
InteractionSensor Area3D overlaps
 -> S_PlayerInteractionSelection
 -> nearest valid C_Interactable (<= C_InteractionRange, default 2m)
 -> C_InteractionSensor.selected_target
 -> interact_pressed
 -> S_InteractionIntent
 -> InteractionService request
 -> O_Interaction re-validation
 -> interaction_activated
```

Player всегда имеет не более одной выбранной цели: ближайший валидный overlap. `C_Interactable.enabled`, actor range и `C_Interactable.max_distance` проверяются и при selection, и непосредственно перед activation.

### AI hook

AI намеренно **не** использует правило `nearest`. Будущий Utility AI / Behavior Tree / GOAP записывает требуемую цель в `C_AIInteractionGoal.target` и поднимает `request_interaction`. `S_AIInteractionSelection` лишь проверяет, находится ли эта конкретная цель в sensor Area3D и валидна ли она. Поэтому AI сможет выбирать кнопку, дверь или рычаг по задаче, а не по геометрической близости.

### Optional drawing

Interactable может иметь `C_InterractDrawing`. Тогда выбранная local-player цель получает presentation overlay/highlight. Без компонента объект остаётся полностью интерактивным, но не подсвечивается.

`O_Activatable` является минимальным примером реакции: target с `C_Activatable` переключает состояние. Реальная дверь может использовать тот же activation event и запускать animation/physics transition.
