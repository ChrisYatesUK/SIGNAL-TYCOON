# 18 · Performance contact sheet and measurement plan

**Intent.** The busiest permitted studio server should remain usable on a modest phone. This is an asset budget and a measurement procedure, not a measured FPS result or a promise that imported source material counts equal Roblox draw calls.

**Test device target.** Physical Samsung Galaxy A13 4G, 4GB RAM, Exynos 850 variant, 60Hz display; record the exact model/OS/Roblox version actually tested. This is a chosen test configuration, not a claim of universal device specs. Run at normal room temperature and include a 20-minute warm-up/thermal session. Compare with a capable desktop targeting 60 FPS. Device Emulator checks layout only and cannot prove mobile performance.

## Permitted load and provisional budgets

| Item | Studio place target | Marketplace place target |
|---|---|---|
| Players / plots | 12 players; all 12 claimable Large envelopes | Test both 20 and 30 players; no studio plots |
| Placeables | 100 each = 1,200 allowed; mostly static | Fixed environment, no arbitrary player furniture |
| Crew | Start with 2 active visual rigs per plot = 24; preserve server work offscreen | No working crew; 30 avatars plus environment |
| Visible triangles | Initial target ≤250k near-camera scene including avatar geometry; measure | Initial target ≤250k with 30 avatars; measure |
| Draw calls | Initial scene target ≤350 opaque/material submissions after import/tuning; profile actual engine counts | Target ≤350, then measure avatar/SurfaceGui cost |
| Textures | Shared 512² equipment/palette sheets; ≤1024² for exceptional single board; no per-card image copies | Reuse same card sprites; page listing thumbnails |
| Dynamic lights | At most 2 optional visible lights; baseline equipment uses none | At most 2 optional accents |
| Particles | ≤12 per confirmed reveal; ≤24 simultaneously near player; no persistent emitters | 0 baseline; later event cap 48 for capable mode only |
| Transparent overlap | Prefer 0; at most 2 meaningful layers in a local reveal | Opaque card backing and one surface display |
| UI live instances | One open modal; initially 20 result rows/page; destroy offscreen prior page | Same bounded rows, no 30-player inventory preload |
| Memory | Establish actual idle baseline; provisional total client target ≤700MB and ≤20MB retained growth across repeated UI cycles | Record 30-avatar baseline separately |

These numerical budgets are proposals. Any imported avatar, mesh or renderer behaviour can change the cost. Avatar triangles are not controlled solely by the environment artist. Retain a simpler quality tier if ordinary player avatars exceed the initial geometry budget.

## Contact sheet and estimate method

`visuals/Asset-Contact-Sheet.html` uses actual pack previews, extracted sprite samples and playable selected audio, labelled with exact source paths. `assets/Asset-Register.csv` contains source SHA-256 and imported-ID placeholders. `assets/Selected-Asset-Metrics.csv` counts OBJ triangulation estimates from source faces and unique referenced source materials, before any Roblox import. For opaque meshes, a first planning approximation is one material submission per visible mesh/material section. Batching, instancing, shadows, culling and texture changes can alter this, so it is not a measured Roblox draw-call count. UI sprites are 0 added uploads when native geometry replaces them, otherwise one image/material binding before renderer batching. Audio has zero draw calls; particles create overdraw rather than a reliable per-particle draw-call count.

**Selection vs final art.** Furniture/cabinet/window previews are real source asset images. Original equipment and characters appear in the separate specification drawings and have proposed budgets; they are not final 3D previews. Optional A04 sprites are included for artist use while the UI runtime uses native Frames/UICorner controls to minimise extra textures.

## Reduced-effects coverage

| Effect | Standard proposal | Reduced effects |
|---|---|---|
| Production complete | 8 circle particles, ≤0.5s | No particles; static Ready state |
| Drop reveal | 12 star particles, one 450ms reveal | Word/shape/card appears instantly |
| Upgrade | Short sound and 160ms highlight | Sound follows volume; static new equipment state |
| Staff | Short working loop/one celebration | Calm pose; omit celebration |
| Award Show, later | Bounded burst, no flashing | No particles/camera motion; static reward summary |
| UI opening | Optional 160ms transition | Immediate panel swap |
| Lighting | At most 2 local optional accents | Optional lights disabled |

## Studio procedure

1. Import the chosen models with shared textures, anchor static meshes, and use simple collision proxies. Measure actual mesh/material cost before mass cloning. Disable CastShadow on small trim and hidden submeshes.
2. Turn on StreamingEnabled in Studio. Start MinRadius=64, TargetRadius=160; tune with actual movement, memory and streaming. Do not mark all 12 full plots Persistent. Critical GUI uses replicated summaries independent of streamed world instances.
3. Fill every plot to the full 100 permitted objects, including a worst-case approved mix; also test a visually repeated desk-heavy scene for batching. Set every plot Large and load 24 allowed active crew plus 12 players. Do not test only nearby plots and call it a full-load pass.
4. Measure standing at spawn, looking down the full boulevard, walking to P12, entering a dense studio and opening/reopening every UI panel. Record frame-time percentiles, frame drops, memory, draw calls and triangle counts with Developer Console/MicroProfiler available on the test setup.
5. Sustained phone goal: median frame time ≤33.3ms after warm-up and p95 ≤40ms, no recurring long stalls. Capable-device goal: median ≤16.7ms. Report the actual percentile trace, device temperature context, graphics quality and network conditions; never use a screenshot FPS peak as proof.
6. Run 30-player marketplace as a separate test. Trade mutations can be synthetic server fixtures in an isolated test place; graphics tests must still use the actual player/avatar load.
7. If failing, first reduce visible geometry/material variation, then cull distant display surfaces and crew animation, remove optional lights/transparent layers, and tune streaming. Keep touch size, rarity labels and confirmation information intact. Retest only the failing scenario plus its nearest affected path.

**Luau.** EffectsController and scoped renderer cleanup reduce client overhead. Engineering must integrate distance-based crew/display culling and permitted catalogue budgets; no server/performance simulator is included.

**Open questions.** Physical device and Roblox profiling remain to be performed after import. No FPS, memory or draw-call acceptance result is claimed for this design pack.
