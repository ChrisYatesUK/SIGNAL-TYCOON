# 03 · Small, Medium and Large studio plots

**Intent.** A starter room should feel finished while visibly allowing growth. All sizes share one immutable origin and a fixed entrance at local Z=+24, so furniture positions and neighbours never shift during expansion.

## Variant specification

| Variant | Buildable X range | Buildable Z range | Floor centre / size | Grid cells | Entrance apron |
|---|---|---|---|---|---|
| Small | −12…12 | −12…12 | (0,−0.5,0) / 24,1,24 | 12×12 | 8 wide, Z=12…24 |
| Medium | −18…18 | −18…18 | (0,−0.5,0) / 36,1,36 | 18×18 | 8 wide, Z=18…24 |
| Large | −24…24 | −24…24 | (0,−0.5,0) / 48,1,48 | 24×24 | no extra apron |

The stated floor is a nominal envelope. Reserve a one-stud wall strip and a 6-stud central circulation route from the entrance to the room centre. Server catalogue footprints must remain inside the usable floor and outside architecture/route exclusion volumes. Store placement centres on the 2-stud lattice; use even-dimension footprints (2,4,6,8…). Physical furniture may be smaller than its reserved cell footprint. No arbitrary player scale, tilt or non-90° rotation.

## Numbered part schedule

For each variant let W=24/36/48, H=W/2. All parts are relative to the plot origin, yaw 0, SmoothPlastic, Anchored=true, CanTouch=false. Structural parts collide and are queryable. Decor and grid do neither.

| Step / part | Size X,Y,Z | Position X,Y,Z | Colour / setting |
|---|---|---|---|
| 1 Floor | W,1,W | 0,−0.5,0 | Surface |
| 2 RearWall | W,10,1 | 0,5,−H+0.5 | Raised |
| 3 LeftWall | 1,10,W−2 | −H+0.5,5,0 | Surface |
| 4 RightWall | 1,10,W−2 | H−0.5,5,0 | Surface |
| 5 FrontLeft | H−4,6,1 | −(H+4)/2,3,H−0.5 | Raised |
| 6 FrontRight | H−4,6,1 | (H+4)/2,3,H−0.5 | Raised |
| 7 EntranceLintel | 8,1,1 | 0,7.5,H−0.5 | Primary; 7-stud clearance |
| 8 RearAccent | W−4,0.25,0.15 | 0,8,−H+1.05 | Brand; no collision |
| 9 Apron (Small/Medium) | 8,1,24−H | 0,−0.5,(H+24)/2 | Surface |
| 10 Boundary rear | 48,0.1,0.15 | 0,0.05,−24 | Muted; noncolliding |
| 11 Boundary left/right ×2 | 0.15,0.1,48 | ±24,0.05,0 | Muted; noncolliding |
| 12 Nameplate | 8,2,0.2 | 0,9,H−0.3 | Ink; noncolliding SurfaceGui facing +Z |

13. Group architecture in `Shell`, decor in `Theme`, equipment in `Equipment`, and local preview/grid objects outside saved placement data. Model pivot is exactly `(0,0,0)`. Set size variant and plot ID attributes for the engineer; shell exchange is an authoritative engineering action.

14. Make the build overlay client-only. For X and Z from −H to +H in steps of 2, draw 0.04-stud-wide line strips at Y=0.035; 26 / 38 / 50 strips respectively. Colour valid footprint cyan plus check symbol; invalid footprint coral plus cross and a localised reason. Grid visible only while building on your permitted plot. It does not count toward the 100-placeable budget and is destroyed on exit.

15. Fit every imported model to the registered footprint, floor-centre its pivot and face it +Z at zero rotation. Use simple collision proxies; equipment and crew route proxies queryable, ornamental leaves/cables not. Reject mesh collisions that snag feet or block the entrance.

16. Install the selected theme using sections 04 or 05. On expansion, leave all existing placements unchanged. Replace perimeter architecture and reveal the added floor; remove the old apron where it overlaps newly usable space. Rebuild the local grid. Display old/new footprint in a confirmation preview before the server action.

17. Reserve all twelve full envelopes immediately. Each plot has 100 placeables at every size initially; expansions change space, not the stated performance cap. Starter equipment and gameplay furniture count in that limit. Shell, claim marker and fixed signage do not; budget them separately. Start with at most two visible working crew per plot, subject to the performance gate.

**Wireframe.** `visuals/Site-and-Plots.svg` includes a 2-stud overlay and nested floor envelopes. The entry at +Z stays in the same world corridor even when the room entrance moves outwards.

**Luau.** `PlacementController.lua` provides local 2-stud preview stepping, rotation and cleanup. It fires intent through the shared UI adapter; it cannot claim, expand, save, bill or approve overlap.

**Asset list.** Native floor/walls/grid, A03 decorative window treatment, original nameplate; A01 furniture in theme guides. No imported collision solver.

**Test notes.** Verify all numeric envelope edges and pivots in Studio; try a rotated 8×4 footprint at each boundary; move/store an active job’s equipment and confirm server rejection is explained. Test all three sizes in each of twelve positions. Check mobile touch placement and gamepad stepping without cursor precision. Expansion must not displace existing objects.

**Open questions.** Exact expansion costs and follower unlocks come from server catalogue configuration; this design deliberately specifies no economy values.
