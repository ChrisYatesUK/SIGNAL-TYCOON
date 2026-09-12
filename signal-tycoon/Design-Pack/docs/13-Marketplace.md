# 13 · Marketplace hub and UI

**Intent.** A convention lounge gives 20–30 players a social destination while the accessible listing interface does the detailed comparison work. Original provenance and exact terms carry more visual weight than decorative rarity glow.

## Hub construction

Separate place, local origin floor top centre. Parts anchored, SmoothPlastic, collision/query true, touch false; decor meshes noncolliding with one simple proxy where needed. Model pivots floor-centred, forward +Z. Do not reuse plot capacity as marketplace capacity.

| Step / part | Size | Centre / pivot | Colour / notes |
|---|---|---|---|
| 1 HallFloor | 80,1,64 | 0,−0.5,0 | Surface |
| 2 RearWall | 80,14,1 | 0,7,−31.5 | Raised |
| 3 LeftWall / RightWall | 1,14,62 | ±39.5,7,0 | Surface |
| 4 FrontLeft / FrontRight | 30,10,1 | ±25,5,31.5 | Surface; 20-stud central opening |
| 5 SpawnLocation | 8,0.2,8 | 0,0.1,22 | Invisible, neutral, noncolliding |
| 6 CentralAisle | 16,0.04,50 | 0,0.02,0 | Raised, noncolliding |
| 7 ListingDesk ×4 | 8,3,4 | (±18,0,±12) model pivots | A01.Desk, Ink trim; yaw 0 for rear pair, 180 front pair |
| 8 LoungeSofa ×4 | 6,3,2 | (±30,0,±12) model pivots | A01.Sofa, alternate coral/violet; face inward, yaw ±90 |
| 9 ChartBoard | 12,9,2 | 0,0,−26 pivot | Original, +Z forward |
| 10 DisplayPlinth ×4 | 4,4,4 | (±12,0,−24), (±24,0,−24) | Original; server-approved showcase data |
| 11 ReturnPortal frame | 10,10,2 envelope | 24,0,25 pivot | Three native parts: posts 1×10×2 at x=±4.5,y=5; header 10×1×2 at y=10.5; all relative to frame pivot |
| 12 HelpDesk | 8,3,4 | −24,0,25 pivot | A01.Desk; reporting/help UI access |

13. Add A03 window insets to rear wall at X=±25, Y=8, Z=−30.9, bounds 8×6×0.15, no glass transparency. Keep open ceiling and 16-stud main aisle; no teleport pad at the aisle entrance. Return portal uses explicit action and handles travel failure inline.

## UI specification

Tabs: Browse, My listings, Offers, Trade review. Filters category/series/rarity/type, with bounded paged results. Rows show category, rarity word/shape, series/week and asking terms. Detail always includes dropId, quality, creation time, original creator, current owner and settled status. A provenance viewer labels any limited history as limited; it never claims a complete chain when only original/current owner exists.

Create listing: select eligible Drop → item-for-item/open-offers/optional Credits → terms → server review → confirm. Credits listings remain feature-gated because v2 lists them but leaves launch enablement open. Show server fee and net proceeds if enabled, without a client fee formula. Offer editor supports up to four items per side and optional Credit amount only when allowed. Accepting an offer opens trade review; it is not the irreversible commit itself. Two-sided review shows exact item IDs and all terms, review countdown, both confirmation indicators and clear Cancel. Any edit clears confirmations; a new version must be read again. Final “Trade complete” only comes from durable server confirmation.

**States.** Locked/onboarding, loading, empty, stale listing, seller unavailable, soft-locked, review changed, awaiting partner, committing, complete, recovery pending, teleport failed. Avoid price predictions, market-value guarantees and external contact links. Report and Block remain available from detail/review even when trading is unavailable.

**Wireframe.** `UI-Wireframes.html#MarketplaceHub`; `visuals/Marketplace-Plan.svg`.

**Luau.** `MarketplaceUIController.lua` uses market query/list/cancel/offer/accept/review/confirm/visit/return intents. The client never touches MemoryStore, messaging, inventory locks, escrow or journal state. Confirmation payload carries the exact server review/version token. Closing during committing cannot roll back a trade.

**Assets.** Shared A01 desk/sofa, A03 window, original chart/plinth/Pulse; A04 flat controls; A06 confirmed trade cue. No continuous trading-floor particles.

**Test notes.** Test 30 player avatars, paged browsing, listing disappearing during review, changed terms, two confirmations, server recovery and portal failure. Inspect provenance on 360px phone without truncating IDs in the detail scroll area. Controller focus is tab → filter → list → detail → Cancel → Confirm.

**Open questions.** Credit listing launch gate and the conflicting partnered collectible ownership rules require product/engineering decisions before those releases; UI remains configurable.
