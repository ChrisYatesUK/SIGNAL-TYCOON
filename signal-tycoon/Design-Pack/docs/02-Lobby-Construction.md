# 02 · Lobby and twelve-plot site

**Intent.** The lobby is a small, open arrival pavilion with a straight route to all studios. Every player can claim a plot at launch; a complete 48×48 Large plot footprint is reserved for each, even while its owner uses the Small variant.

## Conventions and site layout

All measurements are studs. World origin `(0,0,0)` is the centre of the lobby floor at its top surface. Part positions below are centres; model positions are floor-centred pivots. +Y is up, +Z is authored model forward. Yaw is in degrees around Y, with no X/Z rotation unless stated. Roblox `CFrame.LookVector` is −Z: do not mistake it for this asset convention. All structural parts: Anchored=true, CanCollide=true, CanTouch=false, CanQuery=true, SmoothPlastic, Reflectance=0. Decorative meshes: anchored, all collision/touch/query false; give walk-blocking furniture a separate invisible simple box proxy. Walkable surfaces remain at Y=0.

The lobby occupies X=−24…24, Z=−24…24. A 16-stud boulevard continues along +Z to Z=388. Six paired studios sit on each side. Plot centres are X=−40 and +40, with Z=60, 120, 180, 240, 300, 360. Left plots yaw +90° (front points +X); right plots yaw −90° (front points −X). Each 48×48 footprint leaves 8 studs between its front boundary and the boulevard. Connect that gap with an 8-stud-wide entrance path. Cross streets at Z=90,150,210,270,330 are optional visual joints within the existing 12-stud inter-row gap, not extra expansion space. World ground X=−80…80, Z=−32…392.

| Plot | Pivot X,Y,Z | Yaw | Plot | Pivot X,Y,Z | Yaw |
|---|---|---:|---|---|---:|
| P01 | −40,0,60 | 90 | P02 | 40,0,60 | −90 |
| P03 | −40,0,120 | 90 | P04 | 40,0,120 | −90 |
| P05 | −40,0,180 | 90 | P06 | 40,0,180 | −90 |
| P07 | −40,0,240 | 90 | P08 | 40,0,240 | −90 |
| P09 | −40,0,300 | 90 | P10 | 40,0,300 | −90 |
| P11 | −40,0,360 | 90 | P12 | 40,0,360 | −90 |

## Numbered construction order

| Step / part | Size X,Y,Z | Centre X,Y,Z | Yaw | Colour / exception |
|---|---|---|---:|---|
| 1 Ground | 160,2,424 | 0,−2,180 | 0 | `#D9E6E9`; top −1 |
| 2 LobbyFloor | 48,1,48 | 0,−0.5,0 | 0 | Surface |
| 3 Boulevard | 16,1,364 | 0,−0.5,206 | 0 | Raised; begins Z=24 |
| 4 WestWall | 1,12,48 | −23.5,6,0 | 0 | Surface |
| 5 EastWall | 1,12,48 | 23.5,6,0 | 0 | Surface |
| 6 RearWall | 46,12,1 | 0,6,−23.5 | 0 | Surface |
| 7 RoofLintelWest | 2,2,48 | −23,13,0 | 0 | Ink; no full roof over camera |
| 8 RoofLintelEast | 2,2,48 | 23,13,0 | 0 | Ink |
| 9 RearPulsePanel | 16,6,0.4 | 0,8,−22.8 | 0 | Brand; decoration, no collision |
| 10 SpawnLocation | 6,0.2,6 | 0,0.1,−10 | 0 | Transparency=1, CanCollide=false; neutral, no forcefield duration |
| 11 TutorialDeskProxy | 8,3,4 | −12,1.5,−4 | 0 | Invisible collision box; model at −12,0,−4 |
| 12 PlayCornerMat | 10,0.1,8 | −15,0.05,10 | 0 | Coral; no collision |
| 13 PortalLeft | 1,10,2 | 10,5,−16 | 0 | Ink |
| 14 PortalRight | 1,10,2 | 20,5,−16 | 0 | Ink |
| 15 PortalHeader | 11,1,2 | 15,10.5,−16 | 0 | Primary |
| 16 PortalScreen | 8,6,0.2 | 15,6,−16 | 0 | Brand; opaque, no collision |
| 17 PlotPath ×12 | 8,1,8 | ±12,−0.5,row Z | 0 | Surface |
| 18 ClaimPlinth ×12 | 4,1,4 | ±12,0.5,row Z−6 | 0 | Primary; off the centre of path |

19. Import the A01 tutorial desk and chair, with the desk facing +Z and chair behind it at `(−12,0,−8)`, yaw 0. Normalise desk bounds to 8×3×4; keep chair in a 2×2 footprint. Add the A02 upright cabinet at `(−17,0,10)` yaw 0, bounds 4×6×4, plus A01 seating at `(−10,0,12)` yaw 90, bounds 4×3×2. Use the asset register for confirmed source paths; none of these props starts a minigame.

20. Import the A03 window module as a decorative inset at `(−22.9,6,−10)`, yaw 90, 0.2×6×8 final world bounds. Keep the native wall as its collision proxy. Add a matching right-wall inset at `(22.9,6,−10)`, yaw −90. Omit animated doors and reflective glass.

21. Fit the Pulse mark to RearPulsePanel with a SurfaceGui on the face towards the room (+Z). Label the marketplace with a localisation key and lock reason when ineligible. The portal is a visual destination; only an explicit button/request initiates travel. No automatic walk-through teleport for a first-time player.

22. Clone the plot template to the twelve pivots. Set `PlotId` attributes P01…P12 for engineer integration. All twelve claim displays must advertise availability at initial server start; no premium or partnership reservation. Claiming is exclusively server-owned.

23. Add daylight with one shared environment lighting setup. The cyan portal is an emissive-looking surface, not a required dynamic light. No moving billboard, strobe, fog wall or transparent portal tunnel. Enable world streaming in Studio; initial engineering tuning target: 64-stud minimum, 160-stud target radius, then profile.

**Wireframe.** `visuals/Site-and-Plots.svg` labels every claimable plot and the growth envelopes. Camera composition: spawn sees Pulse above, free-plot direction ahead, tutorial desk left; market is secondary to the first production.

**Luau.** No world-builder runtime script is supplied; the builder constructs these static parts. Claim, availability and teleport requests consume engineer-provided state. UI transport is in the later client handover.

**Asset list.** A01 desk/chair/seating; A02 upright arcade; A03 window inset; original Pulse logo, portal frame, claim plinth. Exact imported IDs remain pending. Structural native parts supersede complex modular meshes where collision and scale would cost more to adapt.

**Test notes.** Twelve simultaneous solo joins must each reach a different claimable plot. Test return from marketplace into a full studio server with engineering. Walk boulevard with two avatars passing; inspect plot-edge collisions at maximum size. On phone, aim camera from P01 towards P12 and profile streaming; distant plot availability must remain usable through the plot picker even when world props stream out.

**Open questions.** None blocking layout. The engineer owns routing when a claimed studio owner teleports away and the original server later fills.
