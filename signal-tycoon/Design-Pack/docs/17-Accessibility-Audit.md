# 17 · Accessibility audit and release checks

**Intent.** Make the same important information and actions available regardless of input device or colour perception. This is a design/code inspection and a test matrix; physical-device, Roblox and assistive-technology validation is still pending.

## Coverage matrix

| Screen | Non-colour information | Touch / focus order | Localisation and reflow | Reduced effects |
|---|---|---|---|---|
| HUD | Currency words; job state; partnership role | Settings → Production → Partnership → six navigation buttons; ≥48px | Balance line wraps; no scroll; safe insets; exact-value detail elsewhere | Static objective and state text |
| Build | Check/cross footprint, slot names, disabled reason | Filters → items → nudge/rotate/place/cancel; all visible controls | No hover names; catalogue rows expand | No grid pulse or moving arrows |
| Crew | Role, level, XP numerator/denominator | Crew → station → review → assign | Mood absent unless implemented | Static work pose |
| Production | Category name, quality text, phase | Category → crew → equipment → quote → action | Wrap summaries; scroll body only | Instant reveal with word + shape |
| Collection | Rarity word + shape, series and permanent/pending | Filters → result → detail → favourite → salvage preview | Complete creation/provenance details in scroll body | No hover tilt/card spin |
| Chart | Numeric supply, Interest label, provisional wording | Category detail → explanation → refresh | Counts and units localised; no colour-only bars | No chart animation required |
| Partnership | Host/Co-owner words, both contribution totals, deadlines | Parties → vote → leave review → Cancel → Confirm | Long names wrap; retention/refund summary visible | No shaking urgent vote alerts |
| Marketplace | Exact terms, rarity word/shape, provenance/status | Filters → listings → offer → review → Cancel → Confirm | IDs wrap in detail; no truncated terms in confirmation | No trading floor particles |
| Report | Context and category words | Target → reason → optional details → Block/Submit | All statuses keyed; 200-character Unicode draft | Quiet confirmation, no alarm |
| Settings | On/off word; numeric sound percentage | Effects → volume stepper → locale → blocked users → Save | Reviewed locales only, English table fallback | Respects platform reduced motion too |

## Inspection findings addressed

1. Cyan, coral and rarity fills cannot all support small white text. Ink is used for primary actions; rarity labels sit on a pale surface independent of their coloured shape.
2. A 360px phone cannot fit ten simultaneous navigation buttons in one row. Six navigation controls use a compact two-row grid; Settings and partnership remain near the top. Touch bottom reserve protects movement controls. All modal bodies scroll; the HUD does not.
3. A countdown reaching zero is not a server state change. The runtime labels it checking; it does not enable collection, confirm a trade or settle a Drop.
4. TouchEnabled alone cannot identify active input on hybrid devices. Prompt switching observes the most recent input, with capability checks.
5. Rarity glyphs can vary with font coverage. Exact image placeholders and original vector shapes are supplied; until those are uploaded, fallback symbol plus rarity word remains available. Replace fallback glyphs before art acceptance if the target device lacks them.
6. Disabling a ParticleEmitter does not prevent explicit `Emit`. All authored bursts must use the provided Effects wrapper, and optional emitters are cleared on reduced mode. The runtime itself adds no rapid motion.
7. Pending transactions cannot be confidently labelled failed just because the client times out. The UI shows unknown status and preserves the pending lock until a response/reconciliation, instead of duplicating the request.

## Acceptance tests to run in Studio and on hardware

- 360×640 portrait, 640×360 landscape, 1366×768 desktop, controller-only. Include safe cutouts and platform top bar.
- Simulate +35% text expansion; body never below 14px, no clipped action terms, all focusable fields reachable by scrolling. Test platform preferred larger text separately; this prototype uses a fixed 16px body and needs per-user text-size adaptation if required by release testing.
- Inspect in greyscale and two colour-vision simulations; identify all four rarities without colour.
- Turn audio off and reduced effects on before onboarding; finish every milestone and inspect newly streamed emitters.
- Connect/disconnect controllers mid-dialog; Back returns to the opener, and no game action is triggered while a TextBox is focused.
- Destroy UI/respawn repeatedly and check for surviving connections, duplicated SoundGroups or ghost models.
- A screen-reader compatibility review must use the actual Roblox client and supported platform features. Do not infer spoken accessibility from text labels alone.

**Wireframe/assets.** All ten views in `UI-Wireframes.html`; rarity shapes and A05 glyph contact sheet. `QA-Results.md` separates automated artifact checks from unrun engine checks.

**Luau.** Shared safe-inset layout, 48px buttons, explicit selection graph, text-wrapped rows, localisation table and reduced-effects manager implement the baseline. Server-supplied body/detail text must remain localised or already filtered user text as described in the contract.

**Open questions.** Target devices and all release locales need final QA coverage; no claims of universal screen-reader support are made.
