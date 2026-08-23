# Items, Inventory и Equipment

## ItemDefinition

Статическая конфигурация предмета хранится в Resource:

- semantic equipment slot;
- stat modifiers;
- granted abilities;
- optional visual scene/socket.

Runtime Item Entity нужна для уникального ownership/durability/rolls. Inventory хранит ссылки на item instances в `C_Inventory` — это высококардинальные runtime refs, а не structural pair targets.

## Equipment relationship

```text
Player -- R_Equipped(item=<SwordInstance>, slot=main_hand) --> E_Item Script
```

Как и abilities/effects, target relationship стабилен (`E_Item` Script), конкретная instance лежит в relation data.

## Equip pipeline

```text
Equipment request
 -> O_Equipment
 -> EquipmentRuntime
 -> remove old item in slot
 -> add R_Equipped
 -> add R_ModifiesStat(source=item) relationships
 -> grant item abilities through AbilityFactory
 -> presentation_action(equip_item)
```

Unequip выполняет обратные операции. Item-specific systems не нужны.

## Примеры

- Sword: +Damage, выдаёт melee Attack.
- Bow: +Damage/+AttackSpeed, выдаёт Shoot.
- Staff: +Damage, снижает ManaCostMultiplier, выдаёт Fireball.

Все три — `ItemDefinition`, центральная equipment logic не содержит switch по item ID.
