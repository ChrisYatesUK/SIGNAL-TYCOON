# Client UI integration contract

This is a proposed adapter boundary for a competent Roblox engineer, not new authoritative game code. Keep the existing v2 services and Shared modules. The package adds UITypes, UIRemoteDefinitions, Tokens, UILocalization, UIAssets and UIPreview without overwriting Types, CatalogConfig, RarityConfig, RebirthConfig or RemoteDefinitions.

## Transport

Provide three RemoteEvents under `ReplicatedStorage/UIRemotes`: `UIAction`, `UIState`, `UIResult`. Map them to existing per-service remotes if preferred. Bootstrap subscribes before sending `ui.subscribe`. No RemoteFunction is required. No untrusted high-frequency world preview is sent over the network: 2-stud nudges remain local. If a future remote ghost-sharing feature needs UnreliableRemoteEvent, treat it as cosmetic only.

`UIAction` sends `{requestId, screen, action, revision, payload, draft}`. requestId is a client correlation ID, not evidence that an operation is unique or authorised. The server must also enforce ownership, account permissions, expected versions, quotas, valid IDs, finite coordinates, lengths, limits, filters, rate limits and durable idempotency appropriate to the action. Client-supplied credits, quality, rarity or completions are never accepted as facts.

`UIState` sends a monotonically increasing session snapshot revision, HUD summary, saved settings and per-screen view projections. Old revisions are ignored. Each screen has its own revision, ordered rows and optional footer row. The UI keeps draft choices local and carries them on the next intent. The engineer supplies projections from server state; the supplied preview module is never the live source of truth.

`UIResult` sends `{requestId, ok, message={key,args}}`. Message keys must exist in the experience localisation table; unknown keys fall back to a localised unavailable message. Acceptance is not a substitute for the state snapshot that reflects a completed purchase/trade. Results release the pending request indicator. After 12 seconds without a result, UI shows unknown status and does not auto-retry. Reconcile/reconnect before issuing a replacement irreversible action.

## Row schema

| Kind | Additional fields | Behaviour |
|---|---|---|
| label / card | text, detail, optional rarity | Localised label and metadata, rarity word + shape |
| progress | current, maximum | Numeric ratio + bar; display only |
| timer | deadline | Server timestamp countdown; at zero says checking |
| choice | field, value, options[{id,text}] | One local draft choice |
| multiChoice | same; value is array | Up to four local draft IDs, no inventory mutation |
| input | field, value | Local 200-codepoint draft; server revalidates/filter as needed |
| action | action, payload, enabled, reason, confirm, notBefore, bindings | Allowed intent or local settings/preview action; optional review text/deadline; bindings must match draft scalar values |

`text` and `detail` are `{key,args}`. English source phrases exist only in UILocalization / matching import CSV. Numbers, formatted times and filtered player display names may be arguments. Never pass unfiltered player text in a public argument. Do not send an English server error sentence as a key. Add reviewed source keys for all live catalogue names, errors and content beyond the provided fixtures.

Quote `bindings` should include the exact categoryId/crewId/equipmentId or other draft fields that created it. A draft change fails the action guard until a matching quote is received. Server checks both quote identity and expiry. Trade confirmations also carry immutable review/version IDs and a server-provided notBefore; the client confirmation dialog provides a second intentional click, not transaction security.

## Screen-specific state/actions

| Screen | Required live projection | Action family |
|---|---|---|
| HUD | Credits/Followers formatted strings, job phase, completesAt, partnership summary, objective | Local navigation; market travel only by explicit intent |
| Build | Current catalogue/filter results, owned placement IDs, colour slots/swatches, permission and cost reasons | select/place/move/recolour/store/theme |
| Crew | Name/role/XP/current assignment, hire/level quote and owner | hire/level/assign/unassign |
| Production | Category/crew/equipment choices, quality/reward breakdown, quoteId/bindings, job phase/completesAt | quote/start/collect |
| Collection | Paged cards with category/series/quality/created/rarity, favourite, salvage quote, lock reason | query/select/favourite/salvageQuote/salvage |
| Chart | Week/categories, supply counts, Interest rule shares, freshness, provisional score, freezeAt/settlement state | refresh |
| Partnership | Both roles/contributions, account+shared allowance, vote ID/deadline, refund summary/cooling deadline | request/accept/decline/vote/dissolveQuote/dissolve |
| Market | Paged listings, exact provenance, offered item IDs/terms, quote/fee when enabled, both confirmations/review version | query/list/cancel/offer/accept/review/confirm/visit/return |
| Report | Target user/studio/trade context, categories, remaining cooldown/status | report/block/unblock |
| Settings | Reduced effects, sound volume, supported locale list, block rows | local preference change; save/unblock intents |

`ui.report` is a local navigation action: copies subject references into the report draft before opening it. The server validates them when sent. Button bindings use real user IDs, never a displayed name as identity. Runtime preview fixtures contain a zero target ID and PREVIEW identifiers deliberately unusable for live actions.

## Placement integration

Create PlacementController using the commented Bootstrap example. Resolve the selected template from ReplicatedStorage/Assets and the player's permitted plot CFrame from existing placement code, call Begin, and attach it as `ui.placement`. Source template pivots must already be floor-centred +Z forward. The UI’s local nudge/rotate/cancel/submit controls then call the controller. Cancel on leaving Build and on confirmed placement; preserve preview on rejected placement. Existing raycast placement can call SetPoint with a plot-local point. Server validation remains unchanged.

The renderer uses native list components for catalogue previews. A world ghost requires the supplied template hookup; it is not fabricated from a placeholder asset ID. Static plot/grid construction is specified in 02–05; no runtime world builder or server placement code is included.

## Remaining integration and visual polish

The package is a working **UI presentation scaffold**, with ten data-driven screens, local forms, confirmation, focus, localisation, timers and effect preferences. It is not a complete connected game. The engineer must project live data, attach world placement, supply image uploads/animations, emit only once on new acknowledged collection IDs, handle server reconciliation and run Studio/device QA. Art adapters may replace native panels with selected A04 sprites and apply optional 160ms transitions; static default transitions already satisfy reduced effects. WorldDisplayController binds an existing label; builder supplies the actual SurfaceGui and distance visibility hook.

Read-only preview mode is explicit (`Preview=true` attribute), sends no network gameplay actions, and replies to buttons with a localised design-preview notice. It does not simulate trading, reward grants, hires or placement success.
