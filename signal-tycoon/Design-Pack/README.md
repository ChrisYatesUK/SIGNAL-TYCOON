# Signal Tycoon · environment and UI design pack

**Confirmed decision: all twelve studio plots are claimable from launch.** Each has reserved space for a 48×48 Large studio, with smaller variants sharing the same origin. This pack follows the attached prompt's 18-item work order and v2 engineering plan where it supersedes the original brief/v1.

## Start here

1. Open `visuals/Design-System.html` for the single-page visual rules.
2. Read `docs/02-Lobby-Construction.md` and `docs/03-Studio-Plots.md` beside `visuals/Site-and-Plots.svg`.
3. Continue the numbered specifications through 18. Crew is included in 08 alongside Build Catalogue because it is required in scope but has no numbered slot in the source work order.
4. Open `visuals/UI-Wireframes.html` in a browser for all ten screen mocks. Choose 360px phone or desktop width, then inspect each screen. This is an offline design reference, not a hosted website or live game.
5. Open `visuals/Asset-Contact-Sheet.html` for actual selected Kenney asset previews and audio candidates. Exact source files, licences and hashes are in `assets/`.

## What is included

- Eighteen ordered specifications with intent, dimensions, state/interaction guidance, visual references, asset lists, test notes and open questions.
- Lobby, twelve plot positions, three room sizes, Gaming Den, Vlog Loft and a separate 20–30-player marketplace layout.
- Original Pulse/logo/rarity vector specifications, equipment silhouette references and twelve card treatments. Original 3D assets/rigs are **specified, not modelled**.
- 28 verified Kenney selections from all seven packs: selected unmodified sources and source textures/materials, preserved CC0 licences, exact member names and SHA-256 checksums. Complete original pack ZIPs are retained in `assets/source-archives`; import only the selected entries, not every source item.
- Client-only Luau presentation scaffold: ten screens, local forms, confirmation dialogs, timers, input prompts, focus, localisation, reduced effects and a placement preview adapter.
- English localisation source in Lua/JSON/CSV; reusable UI action/state contract.
- Performance estimates and a physical-device QA plan. These are targets, not measured Roblox performance.

## Install the UI preview in Roblox Studio

1. In an isolated test place, copy the ModuleScripts from `src/ReplicatedStorage/Shared` into `ReplicatedStorage/Shared`. Preserve existing engineering modules; these files have additive names.
2. Copy `src/StarterPlayerScripts/Controllers` into `StarterPlayer/StarterPlayerScripts/Controllers`, creating ModuleScripts with the file basenames.
3. Create a **LocalScript** named `UIBootstrap` under `StarterPlayerScripts` and paste `UIBootstrap.client.lua` into it. The filesystem shorthand `StarterPlayerScripts` maps to that Roblox service child.
4. Add a boolean **Preview** attribute to UIBootstrap and set it to **true**. Press Play. The client creates the ten named ScreenGuis in PlayerGui, with HUD initially visible. No server remotes are required for this preview.
5. Use Settings and the six navigation buttons to inspect all screens. Report opens from the market detail action. Button actions in preview mode show a design-only notice and grant nothing.
6. For live integration set Preview=false, read `docs/UI-Data-Contract.md`, bind the three existing/proposed UI RemoteEvents, and supply server view projections. Do not publish preview fixtures as live game state.
7. To see a world placement ghost, attach PlacementController using the Bootstrap integration example and an actual imported model template/plot CFrame. Until that hookup exists, catalogue rows and local forms can be inspected but no 3D template is available to display.
8. Import `assets/Localisation-Source.csv` into the experience’s localisation workflow. Keep English source fallback. Add reviewed language columns before offering additional locales. Replace PENDING image/audio references only after creator-owned upload and permission checks.

## Boundaries and remaining work

This is an artist/UI handover with a reusable presentation implementation. It is not an openable `.rbxl`, a finished connected game, or a claim of Roblox Studio/device validation. There is no server logic, DataStore code, economy calculation, settlement implementation, trade commit code or monetisation advantage.

The builder still imports/scales/recolours the selected models and constructs the specified parts. An artist creates the original equipment and rigs from the specifications. The engineer supplies authoritative data, placement selection/validation, transaction recovery, world display culling and release gates. Exact integration points and known v2 ambiguities are documented rather than silently resolved in client code.

The visual references use a browser sans-serif fallback; Roblox UI source uses only the specified Font enums. Included Kenney fonts are deliberately excluded from the selected assets.

## Sources and validation

The three user-supplied project documents and the attached artist prompt establish scope. User confirmation overrides the original eight-plot target. Current primary technical references and Kenney source links appear in `docs/Sources.md` and the selection sheets. `docs/QA-Results.md` records completed artifact checks and the remaining engine/device checks.
