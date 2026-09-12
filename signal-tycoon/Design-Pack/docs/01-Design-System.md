# 01 · Pulse design system

Signal Tycoon · Design revision 1 · 12 September 2026 · Twelve claimable plots at launch

**Intent.** Make creating a studio feel playful and capable. Pale architecture keeps silhouettes clear; cyan identifies the next action, violet identifies Pulse, and coral provides warm decoration. Rarity has its own redundant word-and-shape language.

| Token | Value | Application |
|---|---|---|
| Surface / raised | `#F1F5F9` / `#E2E8F0` | Floors, panels, inactive controls |
| Ink / equipment | `#1E293B` | All small text on light surfaces; equipment bodies |
| Muted ink | `#475569` | Secondary text on Surface |
| Primary | `#22D3EE` | Primary action fill with Ink text |
| Brand | `#8B5CF6` | Large accent areas; avoid small white text on this fill |
| Coral | `#FB7185` | Set details; Ink text when used as a fill |
| Danger ink | `#991B1B` | Destructive wording on `#FEE2E2`; explicit confirmation |
| Focus | Ink outer 3px + white inner 2px | Persistent gamepad/keyboard focus, not colour alone |
| Common | `#94A3B8` + circle + “Common” | Slate chip with Ink label |
| Uncommon | `#22C55E` + triangle + “Uncommon” | Green symbol; label always Ink on Surface |
| Rare | `#3B82F6` + diamond + “Rare” | Blue symbol; label always Ink on Surface |
| Epic | `#A855F7` + five-point star + “Epic” | Purple symbol; label always Ink on Surface |

**Type and spacing.** Use `Enum.Font.GothamBlack` 28 for major headings, `GothamBold` 20 for section headings and 16 for buttons, `Gotham` 16 for body and 14 for supporting text. Never shrink below 14 to fit; wrap or expand instead. Spacing: 4, 8, 12, 16, 24, 32px. Panel corners 12px, control corners 8px; no stacked shadows. Targets: 48px normally, 44px absolute minimum. A 24px icon lives inside the full target.

**Layout.** Measure inside Roblox’s safe inset. At 360×640 use 12px side margins, 8px gaps, a fixed HUD and one modal at a time. Modal bodies scroll; header, Close and primary decision stay visible. At ≥900px use a centred 720px modal or a 360px build side panel. Controller uses the same reading order, a visible focus outline and Back to close; never requires hover. Allow 35% text expansion and a two-line button variant.

**Motion and states.** Press: 80ms; panel: 160ms ease-out; toast: 200ms in, 3s hold; collection reveal: 450ms once; count change: 180ms. No flashing, screen shake or looping attention pulses. Reduced effects: zero travel/scale animations, zero particles; state changes remain immediate with text and shapes. Respect Roblox reduced motion as well as the in-game setting. Focus, selected, disabled-with-reason, requesting, confirmed, rejected, stale and offline are distinct states. Never show a successful purchase or trade until acknowledged by the server.

**Wireframe.** `visuals/Design-System.html` is the single-page style sheet. `Tokens.lua` implements the same tokens. Pulse mark: one rising three-bar signal with a broken circular enclosure; wordmark uses GothamBlack, not a custom font. All player-facing text comes from localisation keys, including errors, countdown units, prompts and rarity names.

**Assets.** Original Pulse mark and rarity shapes; A04 flat panel/control selection; A05 generic input glyphs; A06 restrained confirmation/cancel feedback. No new font or custom audio upload is required; selected CC0 audio still needs experience-owned upload IDs.

**Test notes.** Verify Ink text on all action fills; inspect greyscale rarity recognition; run 360×640, 1366×768 and controller focus checks. The design target is 4.5:1 body text contrast, 3:1 meaningful UI boundaries. Rarity colour itself is decorative redundancy. Full Roblox and device tests are pending.

**Open questions.** None for these tokens. English source strings ship in the handover; additional translated locales require reviewed translations before being offered to players.
