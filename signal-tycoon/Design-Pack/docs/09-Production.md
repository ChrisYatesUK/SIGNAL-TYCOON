# 09 · Production Panel

**Intent.** Present category, crew and equipment as active choices, with an understandable setup summary before starting. A timer is feedback on a chosen job, not the sole content of the panel.

**Specification.** Header/close 56px; body sections Category, Crew, Equipment, Setup summary; persistent 56px footer. Phone uses one vertical flow with grouped choices; desktop may place summary beside choices. Category has icon + name + theme match explanation. Crew and equipment choices are server-filtered but retain disabled reasons. Summary shows server quality and contribution labels, render duration, expected Credits/Followers and whether Studio or Weekly Series. Do not implement quality or reward formulas in UI.

**States.** Idle selection → server quote → review → Start request → Rendering → Ready → Collect request → Collected. Choices invalidate the previous quote; disable Start until a matching server quote arrives. Rendering shows current job snapshot and one next objective such as arranging decor; changing drafts cannot alter an active job. At zero, show checking until Ready is acknowledged. Collect stays disabled while awaiting a result; reconnect uses saved server timestamps. Guaranteed tutorial Common is explicitly explained once. Pending Weekly final rarity stays unknown, with provisional score clearly labelled.

**Wireframe.** `UI-Wireframes.html#ProductionPanel`.

**Luau.** `ProductionController.lua` requests `production.quote`, `production.start` and `production.collect` through RemoteEvent intents. Form holds categoryId, crewId, equipmentId and quoteId. Server snapshot supplies quote generation/version, jobId, completesAt, phase and quality display. Generic view rows supply contribution values and eligibility; timer uses server time for display only.

**Assets.** Original category icons and equipment/crew thumbnails; A06 confirmed collection cue; A07 single completion burst, omitted under reduced effects.

**Test notes.** Rapidly change category while quote requests return out of order; Start must use the current quote. Disconnect during rendering; reopen with a correct timer. A zero timer cannot enable Collect by itself. Controller focus order is category → crew → equipment → quote → Start/Collect → Close; Back always exits without cancelling the job.

**Open questions.** The engineer must provide a versioned quote projection or equivalent current eligibility state. This is a UI contract, not a new economy rule.
