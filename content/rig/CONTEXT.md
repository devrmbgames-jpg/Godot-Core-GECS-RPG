# Rig and Presentation Context

## Typed route

`Gameplay -> PresentationService.publish -> PresentationActionEvent -> O_RigPresentation -> CharacterRig`.

## Entry points

- `presentation_service.gd` — единственный semantic publish API (`publish`).
- `presentation_action_event.gd` — constructors `simple`, `for_ability`, `for_item`, `for_effect`, `for_target`.
- `character_rig.gd` — imported model/AnimationTree/AnimationPlayer/socket adapter.
- `rig_profile.gd`, `rig_action_binding.gd`, `rig_socket_binding.gd` — typed design mappings.
- `primitive_character_rig.gd` — playground visualization using same contract.
- `rig_locator.gd` — cached scene-tree lookup.

## Important

Не придумывать convenience method по памяти. Перед новым call открыть `PresentationService` и `PresentationActionEvent`; API намеренно маленький и typed.