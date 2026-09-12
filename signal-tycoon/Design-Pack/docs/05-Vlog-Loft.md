# 05 · Vlog Loft

**Intent.** The loft uses daylight, a coral sofa and a calm backdrop to frame a fictional creator’s recording setup. It shares furniture geometry and equipment with Gaming Den, changing composition and approved colour slots instead of creating a second asset pipeline.

## Small room construction, in order

Use the 24×24 shell and conventions from 03/04. Models are anchored, floor-centred +Z forward; yaw below. Meshes do not collide/query/touch. Furniture uses one simple colliding/queryable box proxy; wall decoration, rug, plants and tabletop props need none. Native part positions below are centres.

| Step / object | Source key | Bounds X,Y,Z | Pivot X,Y,Z | Yaw | Material / colour |
|---|---|---|---|---:|---|
| 1 Sofa | A01.Sofa | 6,3,2 | −5,0,−7 | 0 | Coral seat, pale frame |
| 2 Coffee table | A01.Table | 4,2,2 | −5,0,−3 | 0 | Pale top, Ink feet |
| 3 Camera T1 | O.Camera1 | 2,5,2 | −5,0,3 | 180 | Lens faces sofa; Ink |
| 4 Light T1 | O.Light1 | 2,6,2 | −9,0,1 | 180 | Pale ring, coral base |
| 5 Editing desk | A01.Desk | 6,3,4 | 7,0,−6 | 0 | Surface top, warm pale base |
| 6 Computer T1 | O.Computer1 | 4,3,2 | 7,3,−6 | 0 | Shared Ink body, cyan screen |
| 7 Chair | A01.Chair | 2,4,2 | 7,0,−2 | 180 | Pale frame, coral seat |
| 8 Plant | A01.Plant | 2,4,2 | −9,0,−9 | 0 | Desaturated green, pale pot |
| 9 Shelf | A01.Shelf | 4,6,2 | 7,0,7 | 180 | Surface, 4×6×2 proxy |
| 10 Display plinth | O.Plinth | 4,4,4 | −7,0,8 | 0 | Surface base |
| 11 Rug (centre) | O.Rug | 10,0.04,8 | −5,0.02,−5 | 0 | `#F8DDD9`, no collision |
| 12 Backdrop (centre) | O.Backdrop | 10,7,0.15 | −5,3.5,−10.9 | 0 | Warm white `#FFF7ED` |
| 13 Window graphic (centre) | A03.Window | 0.15,6,6 | 10.9,6,−5 | 0 | Opaque pale blue inset, no actual glass |
| 14 Counter | O.Counter | 6,3,1 | 5,5,−10.8 | 0 | Shared Ink frame |

15. Reserve entrance route X=−3…3, Z=0…12; camera and plinth remain left of it. Editor socket `(7,0,−2)`; operator socket `(−5,0,5)`. Give the backdrop a large original three-bar motif in muted coral; no readable real-world poster titles.

16. Keep neutral sunlit surfaces with global daylight. Window is a graphic cue, not a shadow-casting area light. Ring lights do not each create a point light. No transparent curtain layers.

## Medium and Large additions

Medium: add A01 armchair at `(−12,0,10)` yaw 90, second plant at `(12,0,12)`, and a 10×7×0.15 native backdrop centred at `(−10,3.5,−16.9)`. Large: add two 4×4 display footprints at `(12,0,14)` and `(18,0,14)`, shelf at `(−20,0,−16)` yaw 90, and an 8×3×4 shared desk at `(12,0,−16)`. These are catalogue placement suggestions; expansion itself only exchanges architecture. Keep at least 6 studs of passage to every working station.

**Wireframe.** `visuals/Theme-Plans.svg`, right panel. Use the large pale backdrop and one coral sofa as the identifying thumbnail, with a camera in the foreground.

**Luau.** Build Catalogue consumes the Vlog Loft earned theme configuration. No local score formula or passive production bonus is attached to a model.

**Asset selection.** Reuse A01 desk/chair/sofa/table/plant/shelf, A03 window accent, original equipment and displays. Reject kitchen/bathroom/bedroom items, photorealistic foliage and textured brick sets that would require a different material language.

**Test notes.** White/pale items must retain silhouette through charcoal feet and careful ambient contrast. Test brightest display setting, greyscale view, and avatar camera collision beside the backdrop. Ensure operator and editor do not face away from their stations.

**Open questions.** None blocking construction. Theme-category match is supplied by the server and can change only through versioned design configuration.
