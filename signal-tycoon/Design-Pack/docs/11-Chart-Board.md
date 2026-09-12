# 11 · Pulse Chart Board

**Intent.** Explain current category supply and the player’s provisional score without suggesting a chance of winning. The board is informative even when the weekly feature is unavailable.

**Specification.** Top: Weekly Series/week label, Freeze countdown, update age and status. Each category row: icon + name, committed production count, labelled supply bar with numerical value, published Audience Interest share, and “game rule” explanation. Player detail: immutable production quality, provisional score, current projected band labelled provisional, and “Later productions can change this result.” A rarity projection is never called a probability or promised return.

Phone: 56px fixed header, scrollable rows, 56px Refresh/details footer. World board is a summary, with an Open Chart 48px interaction linking to this modal. Desktop can show all categories and explanatory detail side by side. Freshness age and freeze timestamps use server values, never client supply estimation.

**States.** Locked/read-only tutorial; fresh preview; stale preview with last update; frozen but settling; final; low-population edition; unavailable/retry. Reaching countdown zero changes text to “Awaiting settlement”; it does not assign final rarity. Stale data can still be read but cannot masquerade as a live forecast. Low-population edition explains the server’s applied rule without invented production activity.

**Wireframe.** `UI-Wireframes.html#ChartBoard`.

**Luau.** `ChartUIController.lua`, timer renderer and world display binding consume server category counts/interest/scores and `freezeAt`. Request `chart.refresh`; never sum local players as the global supply. Values are server-projected localisation arguments.

**Assets.** Original Pulse board, category icons and rarity shapes; A04 native-style bars; no chart particles.

**Test notes.** Stale connection during Freeze; low population; zero category supply; additional future categories beyond MVP’s three. Gamepad must reach the explanation and Refresh. Compare word labels with colour-blind simulation. Confirm no player-facing “probability” copy in the chart.

**Open questions.** None for presentation. Refresh intervals and finalisation status are supplied by the engineer.
