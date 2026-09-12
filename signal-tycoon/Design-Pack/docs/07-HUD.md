# 07 · HUD

**Intent.** Keep the production loop and essential navigation visible without obscuring movement. Settings is always one tap away; marketplace and partnership can show locked states with explanations during earlier releases.

**Specification.** At 360×640, inside safe insets: top row 48px with Credits, Followers and 48px Settings target; below it a 48px Production timer/status button. A 48px partnership status sits below the timer when enabled. Bottom navigation is two rows of three 48px targets, above an additional 100px touch movement reserve: Build, Crew, Produce; Collection, Chart, Market. Compact numbers come from formatted server display data; do not hide balances behind icons. HUD itself never scrolls. Modal screens suppress all HUD targets until closed. At desktop width ≥900, use a single bottom row and a wider top bar; controller opens focus with ButtonSelect and follows visual order.

**States/transitions.** Loading displays localised loading text without fake zero balances. Idle timer says choose a production; Rendering shows remaining time; Ready says collect; request pending says waiting for confirmation. A local countdown reaching zero says checking completion until server state says Ready. Partnership displays solo/partner name/shared cap indicator, not a purchasable boost. Market shows unlock reason when pressed if ineligible. Server notification badge opens the corresponding offer list.

**Wireframe.** `visuals/UI-Wireframes.html#HUD` contains mobile/desktop/controller width previews; example values are labelled fixture data. All body text ≥14px and targets ≥48px.

**Luau.** `HUDController.lua`, `UIRuntime.lua` and `UIBootstrap.client.lua` create ScreenGui `HUD` and bind `snapshot.hud`. Requires balance display strings, timer phase/completesAt, partnership summary and feature eligibility. HUD navigation is local; travel emits `market.visit` only after the player selects it.

**Assets.** Original Pulse mark; A05 active-device prompts; A06 collect/cancel cues; native text and panels.

**Test notes.** Verify no HUD scroll or overlap at 360×640 safe area; rotate to landscape; connect a controller while touch remains enabled and confirm prompts switch to the last-used input. Test 12-player snapshot updates and respawn without duplicated HUDs. Long balances use a readable formatted compact string, with exact balance in the account/production details.

**Open questions.** None. Safe-area and Roblox touch-control overlap require Studio/device validation.
