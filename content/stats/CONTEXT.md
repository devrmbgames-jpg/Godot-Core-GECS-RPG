# Stats Context

- `stat_modifier_definition.gd` — design-time stat target/operation/amount.
- `ecs/components/attributes/attribute_component.gd` — base/resolved value contract.
- `ecs/components/relationships/r_modifies_stat.gd` — runtime modifier relationship payload.
- `ecs/lib/stat_resolver.gd` — resolve formula.
- `ecs/systems/attributes/s_stat_rebuild.gd` — dirty-driven rebuild.

Formula: `(base + added) * (1 + increased) * product(more)`.

Hot gameplay code reads resolved `.value`; не вызывает resolver при каждом use.