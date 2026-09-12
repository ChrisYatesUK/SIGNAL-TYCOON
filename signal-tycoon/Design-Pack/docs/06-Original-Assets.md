# 06 · Original asset specifications

**Intent.** Own the visual elements players recognise: Pulse, creator equipment, characters and collectible presentation. Purchased or downloaded scenery supports those elements without defining the game’s identity.

## Common production rules

Use floor-centred pivots and +Z forward. Units below are studs, footprint dimensions even. Equipment meshes anchored with one simple base collision proxy; decorative submeshes noncolliding, non-touching and non-queryable. Recolour only named Body, Accent and Trim slots. One shared 512² palette/trim atlas per equipment family, no unique texture per rarity or tier. Triangle counts are authoring ceilings, not measured exports. All asset IDs are placeholders in `assets/Asset-Register.csv` until uploaded by the intended Roblox creator/group. Do not upload custom fonts or commission custom audio for this scope.

| Asset | Bounds / ceiling | Required silhouette and construction |
|---|---|---|
| Pulse mark | 64×64 design canvas; export 256² transparent PNG | Three rising rounded bars at x=18,30,42 with heights 14,24,36; open circular enclosure with upper-right gap. Safe clear space 8 units. Keep recognisable at 24px; no triangle play button. `Pulse-Mark.svg` is the vector specification. |
| Wordmark / UI motif | GothamBlack, 4:1 aspect | Live localised “Pulse” brand label beside mark; no custom glyph upload. UI motif uses three short stepped bars without enclosure. Do not bake functional text into art. |
| Camera T1 / T2 / T3 | 2×5×2 / 4×5×2 / 4×6×4; ≤600/900/1200 tris | T1 small block body + wide lens on tripod; T2 larger shoulder body + side handle; T3 overhead handle + oversized hood + twin side fins. Tier also shown as I/II/III and full localised name. Lens axis +Z. |
| Computer T1 / T2 / T3 | 4×3×2 / 6×3×2 / 6×4×2; ≤400/700/900 tris | Single monitor; wide monitor + tower; wide monitor + tall rounded tower and 3 bars. Avoid three unique live screens. Screen faces +Z, mounting base Y=0. |
| Light T1 / T2 / T3 | 2×6×2 / 4×6×2 / 4×7×4; ≤400/650/900 tris | Ring on pole; rectangular softbox; double-wing softbox. Pale emitter geometry, tier outline grows. No required dynamic lighting. +Z emission direction. |
| Subscriber counter | 6×3×1; ≤300 tris | Charcoal rounded frame; 5×2 readable screen towards +Z. SurfaceGui 600×200, ≤1Hz number refresh, no digit-by-digit part animation. Display Followers consistently with HUD; “subscriber counter” is the prop name only. |
| Card plinth | 4×4×4; ≤500 tris | Solid 4×1×4 base; central support; 2.5×3.5 card plane lifted to Y=1. Opaque card backing and one front UI surface; no hologram stack. Rarity word and shape remain visible. |
| Pulse Chart board | 12×9×2; ≤600 tris | Two solid supports, 12×7 frame, 10.8×6 display at Y=3…9 facing +Z. Opaque screen SurfaceGui ≤1024×640. Distance cull surface after 64 studs; nearby interaction opens accessible full-screen Chart Board. |

## Twelve card treatments

One shared card template; no twelve full-resolution rendered textures. Header: category icon + category name. Centre: simple category artwork. Footer: series, quality, creation time and rarity word/shape; select to open full metadata at phone scale. All card text is UI, not baked into a mesh texture. Pending Weekly cards display “Pending · final rarity after Freeze” with a striped neutral perimeter; never show the provisional rarity as final. Studio Series cards display permanent rarity and “Studio Series · not tradable”.

| Category | Common / circle | Uncommon / triangle | Rare / diamond | Epic / star |
|---|---|---|---|---|
| Gaming | Stylised original controller + slate border | Same + green corner tabs | Same + blue inset frame | Same + purple stepped frame |
| Comedy | Original paired smile masks + slate border | Same + green corner tabs | Same + blue inset frame | Same + purple stepped frame |
| Music | Three-note sound bars + slate border | Same + green corner tabs | Same + blue inset frame | Same + purple stepped frame |

Use rarity shapes as original vector exports in `Rarity-Shapes.svg`, with individual PNG upload placeholders. No reliance on font coverage for the shipped star/triangle. Preview code has a geometric/text fallback until art IDs exist.

## R15 crew

| Name / role | Outfit / proportion | Work animation / celebration |
|---|---|---|
| Remy Byte / Editor | Violet overshirt, charcoal trousers, cyan cuff; 5.5-stud total height, head 1.1 high, shoulder width 1.8, body width scale about 0.9 | Seated type loop 2s, wrists above keyboard; 0.7s fist pump |
| Ari Frame / Camera Operator | Coral utility vest, pale shirt, charcoal trousers; same skeleton, 5.7-stud height, head 1.1 high, shoulder width 1.9 | Standing adjust loop 2.5s; 0.8s nod and open-hand cheer |

Use standard R15 joints and animator compatibility; proportions are visual targets, not new mesh topology. No real creator likeness, brand clothing or paid custom accessories. Rig scale changes must be tested with the same station sockets. Work clips keep feet within 2×2 station area, avoid continuous head bobbing, and have no root translation. Celebrate once on acknowledged collection, never whenever state re-sends. Reduced effects holds a calm working pose and omits celebration. Staff names are fictional seeds, localised where appropriate. Talent Scout and Community Manager rigs are deferred to V3.

**Construction steps.** (1) Block each silhouette with native parts against an R15 reference. (2) Verify phone recognition at 48 studs. (3) Create simple model geometry within the bounds. (4) Apply the shared palette atlas. (5) Name colour slots and add floor pivot. (6) Add one collision proxy and station/attachment markers. (7) Export, import into an isolated Studio place, verify scale and animation permissions. (8) record creator, source file, checksum, uploaded ID and measured triangles in the register.

**Wireframes.** `visuals/Original-Asset-Specs.svg` shows silhouette envelopes; `visuals/Card-Treatments.html` shows the twelve combinations. These are specification drawings, not finished 3D models.

**Luau.** Shared rarity tokens and `WorldDisplayController.lua` bind counter/board text from client-visible server state. No counter or display calculates rewards or settlement.

**Asset list.** Pulse mark/wordmark/motif, 9 equipment models, counter, plinth, 3 category artworks, 4 rarity shape sprites, 2 R15 outfits, 4 animation clips, chart board. Every upload slot is recorded; no invented numeric ID.

**Test notes.** Review thumbnails at 64px, rarity cards in greyscale, and all equipment tiers from 48 studs. On phone, world displays are summaries; open UI always provides complete readable data. Check animation rest pose and collision without running authoritative jobs.

**Open questions.** Animation and mesh exports require a Roblox artist/Studio session. This package specifies them and supplies vector construction references; it does not claim to contain completed models or uploaded assets.
