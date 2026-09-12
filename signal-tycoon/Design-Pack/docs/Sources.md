# Source register

## Supplied project authority

- `signal-tycoon-design-brief(1).md`: original fantasy, themes, collectible concept and onboarding.
- `Signal-Tycoon-Build-Plan.md`: deterministic MVP quality, Studio/Weekly separation, free resource plan and client/server boundary.
- `Signal-Tycoon-Build-Plan-v2.md`: authoritative revised marketplace, partnership, moderation, capacity and phased delivery.
- `Pasted markdown.md`: artist/UI role, palette, work order and technical constraints.
- User confirmation in this conversation: **all twelve plots should be claimable from launch**.

## Verified asset source pages

Each downloaded archive includes a CC0 licence. The included source register stores its SHA-256 and the exact selected files; original source files are unchanged.

| ID | Source |
|---|---|
| A01 | [Kenney Furniture Kit](https://kenney.nl/assets/furniture-kit) |
| A02 | [Kenney Mini Arcade](https://kenney.nl/assets/mini-arcade) |
| A03 | [Kenney Building Kit](https://kenney.nl/assets/building-kit) |
| A04 | [Kenney UI Pack](https://kenney.nl/assets/ui-pack) |
| A05 | [Kenney Input Prompts](https://kenney.nl/assets/input-prompts) |
| A06 | [Kenney Interface Sounds](https://kenney.nl/assets/interface-sounds) |
| A07 | [Kenney Particle Pack](https://kenney.nl/assets/particle-pack) |

## Roblox primary implementation references

- Use safe inset configuration on screen interfaces. [ScreenGui reference](https://create.roblox.com/docs/reference/engine/classes/ScreenGui)
- Select translators through LocalizationService and keep a keyed fallback table. [LocalizationService](https://create.roblox.com/docs/reference/engine/classes/LocalizationService), [LocalizationTable](https://create.roblox.com/docs/reference/engine/classes/LocalizationTable)
- Use input capability flags and last input changes for device prompts; gamepad selection and reduced motion come from the corresponding engine services. [UserInputService](https://create.roblox.com/docs/reference/engine/classes/UserInputService), [GuiService](https://create.roblox.com/docs/reference/engine/classes/GuiService)
- Streaming and geometry/material budgets require actual scene profiling. The numeric targets in this handover are design proposals. [Instance streaming](https://create.roblox.com/docs/workspace/streaming), [Design for performance](https://create.roblox.com/docs/performance-optimization/design)
- Syntax checking uses the official Luau command-line compiler. It does not emulate Roblox services or prove Studio behaviour. [Luau releases](https://github.com/luau-lang/luau/releases)

External pages were consulted on 12 September 2026. No cited source establishes a measured FPS result for this unbuilt environment.
