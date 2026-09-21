---
name: professional-game-design
description: >
  Review and design game mechanics professionally: core loops, player decisions, game feel,
  onboarding, progression, difficulty, balance/economy, level pacing, accessibility, and
  playtesting. Use for mechanic proposals, tuning, GDD decisions, RPG progression, combat feel,
  or asking whether a feature improves the player experience.
---

# Professional game design

Design from the intended player experience backward. A feature is justified by the decisions, learning, expression, tension, or feedback it creates—not by implementation novelty.

## Design workflow

1. **State the player fantasy and design pillars.** Keep 2–4 concrete pillars that can reject features.
2. **Define the loop.** Write action -> feedback -> consequence/reward -> next decision for the 10–30 second loop, then session and long-term loops only if needed.
3. **Identify meaningful decisions.** For each mechanic, specify information, options, tradeoff, consequence, and whether skill can improve the outcome.
4. **Prototype feel before content volume.** Validate movement/combat/interaction timing and feedback before building many enemies/items/levels around weak fundamentals.
5. **Teach -> practice -> test -> combine.** Introduce mechanics safely, give repetition, then add pressure or combinations. Difficulty should breathe rather than rise monotonically.
6. **Make tunables data.** Speeds, timings, costs, cooldowns, curves and thresholds belong in inspectable data/config, not scattered magic numbers.
7. **Playtest a hypothesis.** Define what should happen, observe player behavior, capture failure/confusion/time-to-understand, change one meaningful variable, repeat.
8. **Cut or simplify features that do not reinforce pillars.**

## System design checks

- Prefer a few rules with interacting consequences over many isolated mechanics.
- Preserve player agency: avoid false choices and mandatory optimal options.
- Use randomness to create adaptation, not to erase understandable cause/effect.
- Failure should teach the player what to change; avoid opaque punishment.
- Progression should introduce new decisions/capabilities, not only larger numbers.
- Economy: every persistent resource needs intentional sources, sinks, pacing, and anti-inflation reasoning.
- RPG stats/modifiers must have a clear build purpose and avoid one universally dominant stat/path.
- Rewards should support the core loop; do not add retention mechanics that undermine play quality or player trust.

## Game feel

Feedback is presentation layered on valid simulation:
- input response first;
- readable animation/audio/VFX/camera feedback second;
- stronger feedback for more important events;
- return quickly to a neutral state;
- do not make screen shake/hit stop corrupt simulation or block essential input.

Provide reduced-motion/flashing options when using strong visual feedback.

## Level and encounter design

- Derive spaces from real player movement/camera/combat metrics.
- Block out and playtest before art dressing.
- Maintain a readable critical path with optional discovery.
- Alternate tension and recovery.
- Use landmarks, lighting, composition and affordances before invisible walls or excessive UI arrows.
- Required challenges should have safety margin; reserve precision limits for optional mastery.

## Review output

When asked to evaluate a mechanic, return:
- intended experience;
- what decision/skill it creates;
- risks/failure modes;
- smallest prototype;
- measurable playtest questions;
- tunable parameters.

Do not present taste as fact. Separate design goals, hypotheses, and observed evidence.

## Related project skills

Use `godot-4-7` for engine implementation, `gecs-v8` for gameplay architecture, and `gut-testing` for deterministic rule tests.

This skill is independently written. Useful external inspiration includes the Apache-2.0 `game-feel`, `level-design`, `physics-tuning`, and `rpg` skills in `gamedev-skills/awesome-gamedev-agent-skills`; do not copy third-party skill text into project code without checking its license.
