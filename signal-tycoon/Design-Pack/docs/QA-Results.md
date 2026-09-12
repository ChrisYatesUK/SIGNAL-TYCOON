# Artifact validation · 12 September 2026

## Completed

| Check | Result | Scope |
|---|---|---|
| Ordered deliverables | 18 numbered documents present | Crew included in 08; market interior included in 13 |
| Twelve claimable plot positions | 12 unique pivots, 48×48 reserved envelopes, 60-stud row spacing | Static specification and rendered SVG inspection |
| Luau syntax | 24 files compile without syntax errors with official Luau 0.738 | Syntax compilation only; Roblox engine types/services are not executed |
| Localisation key coverage | No missing keys among supplied fixtures and statically referenced source keys | 196 English source entries; dynamic future content needs additional keys |
| Phone wireframe overflow | 10/10 screens have no horizontal overflow at 360×640 | HTML reference, not Roblox runtime |
| Phone wireframe target height | No button below 44px across all 10 screens | HTML reference; runtime declares 48px targets |
| Browser script execution | No page errors across all screen selections | Headless Chromium 151 |
| Single-page design reference | Rendered content 794×1076px | Fits within A4 CSS page height at 96dpi; no separate PDF supplied |
| Source contact previews | All 23 embedded source images load | Five audio candidates also embedded with playback controls; listening acceptance pending |
| Kenney selections | 28 selected source paths found in downloaded archives; SHA-256 recorded | Original licence text and model dependencies preserved |
| Source geometry metrics | Nine OBJ sources counted for face triangulation/material references | Estimates before import, never asserted as Roblox draw calls |
| Visual inspection | Site/grid plan, theme floor plans, design system, HUD, Production and contact sheet inspected | Wireframes/spec drawings, not final 3D scene |

## Pending before game release

- Roblox Studio execution and Script Analysis with the actual engine API types. Syntax success cannot prove the client code behaves correctly under engine events.
- Live server projection/RemoteEvent adapter, inventory/quote/review version checks, transaction recovery and feature gates.
- Placement adapter hookup, native world construction, Kenney scale/recolour/material cleanup, collision proxies and upload permissions.
- Original equipment, staff rigs/animations, final card artwork and uploaded image/audio IDs.
- Controller focus and onscreen keyboard behaviour in the actual Roblox clients; long translations, preferred text size and device safe cutouts.
- Physical phone load/thermal profiling with 12 fully furnished plots and 24 active crew; separate 30-player marketplace profiling.
- Full first-time-player onboarding timing and accessibility playtests.
- Audio listening/loudness approval and optional transition/particle polish through the reduced-effects wrapper.

No `.rbxl` export, successful Roblox gameplay test, measured mobile FPS, actual draw-call count, or uploaded Roblox asset is claimed by this handover.
