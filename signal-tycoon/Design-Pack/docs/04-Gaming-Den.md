# 04 · Gaming Den

**Intent.** An oversized dark workstation is the focal point, with a single arcade silhouette and cyan/violet wall accents. Clear floor and restrained screen count prevent a small phone view becoming a wall of glowing rectangles.

## Small room construction, in order

Use the 24×24 shell from 03. Positions below are floor-centred model pivots except native parts, whose centres are explicitly marked. Models face local +Z at yaw 0. All are anchored. Visible meshes have CanCollide/CanTouch/CanQuery=false; only listed simple proxies collide and query, never touch. No dynamic lights, screens animate only during a meaningful state change.

| Step / object | Source key | Bounds X,Y,Z | Pivot X,Y,Z | Yaw | Material / colour / proxy |
|---|---|---|---|---:|---|
| 1 Desk | A01.Desk | 8,3,4 | −6,0,−6 | 0 | Ink top, Surface legs; 8×3×4 proxy |
| 2 Chair | A01.Chair | 2,4,2 | −6,0,−2 | 180 | Brand seat; 2×2×2 proxy; crew socket behind desk |
| 3 Computer T1 | O.Computer1 | 4,3,2 | −6,3,−6 | 0 | Ink + cyan screen; noncolliding tabletop item |
| 4 Camera T1 | O.Camera1 | 2,5,2 | 2,0,−2 | 0 | Ink body; 2×1×2 base proxy |
| 5 Light T1 | O.Light1 | 2,6,2 | 6,0,−2 | 0 | Pale ring, violet base; 2×1×2 proxy |
| 6 Arcade cabinet | A02.Upright | 4,6,4 | 7,0,−7 | 0 | Ink, cyan sides; 4×6×4 proxy |
| 7 Couch | A01.Sofa | 6,3,2 | −7,0,7 | 90 | Violet upholstery; 6×3×2 local proxy |
| 8 Drop plinth | O.Plinth | 4,4,4 | 7,0,7 | 0 | Surface base; 4×1×4 proxy |
| 9 Rug (native part centre) | O.Rug | 10,0.04,8 | −5,0.02,−4 | 0 | Dark violet `#43336A`; no collision |
| 10 Pulse wall panel (centre) | O.WallPanel | 8,4,0.1 | −5,6,−10.9 | 0 | Primary field, Ink mark; no collision |
| 11 Subscriber counter | O.Counter | 6,3,1 | 5,5,−10.8 | 0 | Ink; mounted, no collision |

12. Reserve clear six-stud aisle X=−3…3, Z=2…12. The camera at Z=−2 does not obstruct the entry aisle. Workstation actor stands at `(−6,0,−2)`; the chair is a cosmetic seat unless the engineer supplies sit behaviour. Use one Editor first; the Camera Operator socket is `(2,0,−4)`, not on top of the camera.

13. Add A03 window trim on the side wall only if it fits the 2-stud modular scale without bevel rework. Replace elaborate screens with a single original Pulse panel texture. Remove source advertising/decals rather than trying to mimic a real platform.

## Medium and Large additions

Keep the Small arrangement in place. Medium adds a second A01 desk at `(−12,0,−12)` yaw 0 with 8×3×4 bounds, A01 shelf at `(12,0,−12)` yaw 0 with 4×6×2 bounds, and a plant at `(12,0,12)` in a 2×2 footprint. Large adds lounge seating at `(−16,0,14)` yaw 90, a nonfunctional spare arcade at `(16,0,−16)`, and two display plinths `(12,0,12)` and `(18,0,12)`. Move the Medium plant to `(20,0,18)` only with the player’s placement action; the automatic shell expansion never moves it. Optional additions are player catalogue choices, not a free reward or automatic overwrite.

**Wireframe.** `visuals/Theme-Plans.svg`, left panel, shows the Small layout and clear entry route. Desktop composition: workstation rear left; mobile camera can orbit from entrance without a roof clipping through it.

**Luau.** UI reads the earned Gaming Den theme ID and server-supplied quality contribution. Decorative copies and cosmetic colours do not change quality. Theme activation is a request through Build Catalogue.

**Asset selection.** Keep A01 desk/chair/sofa/shelf/plant and one A02 upright silhouette. Reject beds, kitchens, toilets, pinball clusters and additional animated machines: they add catalogue noise or material variety without strengthening this set. The selected arcade is decor only.

**Test notes.** View from 12, 24 and 48 studs on a phone: camera, computer and ring light must be distinguishable. Walk all actor paths; inspect chair/socket overlap during working animations. No geometry should cover the Production button or camera focus.

**Open questions.** None for art. Functional unlocks and staffing permissions remain configuration data.
