# 14 · Report and Block flow

**Intent.** A player can report an uncomfortable interaction without navigating away or explaining technical identifiers. Blocking is a separate explicit action, with a clear description of its in-experience effect.

**Specification.** 56px header; target/context card; radio choices Scam attempt, Harassment, Offensive name, Other; optional 200-character local input; submit footer. Trade/studio/player context IDs are bound to the selected subject and sent as opaque references. The server determines authoritative evidence. Avoid collecting personal information. Report text is private input until submission; only server-filtered user text can be shown to other players.

Block button opens a summary: prevents in-experience trade offers, partnership requests and studio visits. Do not label it a Roblox account-wide block unless a separate supported Roblox flow actually performs that action. Confirm Block emits the target user ID. Settings offers the corresponding Unblock list. Reporting and blocking do not automatically perform one another.

**States.** Ready, submitting, received, cooldown with server reset time, unavailable/retry, blocked/unblocked acknowledged. Report received is not a finding of guilt. A rate limit applies based on server response; do not show a locally invented remaining daily allowance. Cancelling before send discards the draft after confirmation only when text is present. No arbitrary ban/unban buttons for ordinary users.

**Wireframe.** `UI-Wireframes.html#ReportDialog`.

**Luau.** `ModerationUIController.lua`: `moderation.report`, `moderation.block`, `moderation.unblock`. Includes target type/id and selected category; server validates subject, length, limits and permissions. The optional text box is multiline, wraps and stays above the onscreen keyboard through normal scrolling. Dynamic statuses are localisation keys/arguments.

**Assets.** Native radio/control shapes, A04 check marks, A06 soft confirmation/error. No alarm or shaming graphic.

**Test notes.** Double submit, rate-limit response, block and immediate incoming offer, reopening from a completed trade, controller text keyboard and 200-character Unicode input. Test very long filtered display names without losing Submit or Close.

**Open questions.** Moderation team escalation policy is an operational dependency. No client-side IP/device fingerprint collection is included; those v2 engineering suggestions are not a UI capability.
