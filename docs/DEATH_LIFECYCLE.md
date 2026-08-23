# Death lifecycle

`O_Damage` добавляет marker `C_Dead`, когда Health достигает нуля. `O_Death` реагирует один раз:

- очищает controller intent;
- обнуляет управляемую часть CharacterBody locomotion;
- отменяет active `C_Casting` через CommandBuffer;
- публикует semantic `death` presentation action и `actor_died` event.

Loot, respawn, corpse cleanup и experience могут слушать `actor_died`, не изменяя Damage observer.

RigidBody после смерти не получает новые motor commands от AI (AI chase исключает `C_Dead`) и продолжает естественную физику Jolt.
