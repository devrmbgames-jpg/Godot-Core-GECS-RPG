# Архитектура ядра

## 1. Authority данных

У каждого gameplay-значения должен быть **один источник истины**.

### Godot-authoritative physical body

Для обычного третьего лица:

- `CharacterBody3D.global_transform` — фактический transform.
- `CharacterBody3D.velocity` — фактическая velocity.
- `RigidBody3D.linear_velocity/angular_velocity` — фактическое rigid-body состояние.

ECS хранит intent и параметры: speed, acceleration, gravity, desired direction, controller state. `C_Position`/`C_Velocity` не создаются автоматически только потому, что проект использует ECS.

### ECS-authoritative simulation

Для массовых bullets/agents/server simulation допустима другая модель: `C_Position`/`C_Velocity` являются authority, а RenderingServer/PhysicsServer лишь отображают состояние. Нельзя смешивать оба режима для одного объекта без одностороннего sync-contract.

## 2. Четыре вида данных

| Вид | Пример | Хранилище |
|---|---|---|
| Design definition | base mana cost Fireball | `Resource` |
| Resolved stat | move speed, armor | типизированный `C_* : AttributeComponent` |
| Runtime resource/state | HP.current, Mana.current, cooldown.remaining | обычный `Component` |
| Physical state | transform, actual velocity | Godot body либо ECS, но не оба |

## 3. Component и Relationship

Component отвечает на вопрос **«что есть у Entity?»**:

`Player + C_Health + C_MoveSpeed + C_ControllerIntent`.

Relationship отвечает **«как Entity связан с чем-то?»**:

`Player --HasAbility--> FireballAbility`, `Player --ModifiesStat(from Sword)--> C_Damage`.

Relation является Component instance и может хранить данные самой связи.

### Cardinality rule для GECS v8

Exact Entity target является частью archetype pair key. Поэтому relationship к уникальному transient target не надо использовать автоматически для каждого projectile/hit/effect.

- Небольшая стабильная topology (`Player -> Ability`, `Item -> Owner`) — хороший кандидат.
- Высокочастотная/высококардинальная transient ссылка (`Projectile #19372 -> unique target`) — обычно поле component/request.
- Для stat modifiers target — **Script stat type**, а источник modifier хранится внутри relation data; это сохраняет маленький набор pair keys.

## 4. Когда связь превращать в Entity

Relationship хорош, пока связь маленькая: slot, modifier amount, ownership.

Если объект имеет собственные duration/ticks/stacks/phase/interrupt/network state и его должны независимо обрабатывать несколько systems, он становится Entity. Примеры: projectile, сложный status effect, длительный cast.

## 5. Managers

Допустимы stateless helpers и boundary queues. Не допускается manager, который одновременно владеет состоянием abilities, effects, cooldowns, animations и items.

Вместо этого:

- состояние — Components/Relationships/Entities;
- обработка — Systems;
- реакция на структурные события — Observers;
- presentation — rig/VFX/audio adapters;
- UI/network/input могут создавать requests в известной точке кадра.

## 6. Structural changes

Добавление/удаление Entity, Component и Relationship внутри System выполняется через GECS `CommandBuffer`. Часто меняющееся числовое значение не должно кодироваться постоянным add/remove components, если достаточно изменить поле существующего component.

## 7. Naming

- `C_*` — обычный Component.
- `R_*` — Component, предназначенный для `Relationship.relation`.
- `S_*` — System.
- `O_*` — Observer.
- `E_*` — Entity class.
- `*Definition` — design-time Resource.
