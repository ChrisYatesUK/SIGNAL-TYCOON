# 08 · Build Catalogue and Crew companion

**Intent.** Let players arrange a readable studio with a small set of precise controls. Crew is included here as a companion deliverable because the prompt requires it but omits a separate numbered work-order slot.

## Build specification

Phone modal: 56px title/close header, scrollable catalogue body, 56px persistent action footer. Desktop: 360px left catalogue; preview remains visible in the world. Catalogue filters: equipment, furniture, decor, displays, stored; theme and search in body. Each item row uses an image, localised name, footprint, earned unlock state and Credit cost supplied by the server. A selected item opens Place, Move, Recolour or Store controls. A selected owned placement uses a placement ID, not a catalogue ID.

Placement uses an opaque-outline ghost plus tinted footprint. Touch has Rotate / Place / Cancel targets and four labelled 2-stud nudge buttons; tapping the world may select an initial point through the engineer's placement adapter. Gamepad uses focusable nudge buttons, so precise placement does not rely on mouse input. Keyboard R rotates, Escape cancels; all actions also have visible buttons. Yaw cycles 0/90/180/270. Recolour offers approved slot and swatch IDs, each with a text name and selection check. Move retains ownership; Store is not Sell. A request never subtracts Credits locally.

**States.** Browsing → selected → preview → requesting → server placement acknowledged; rejection returns to preview with reason. Cancel destroys the ghost and leaves saved objects untouched. Local preview validity is advisory. Invalid/outside/busy/locked/cap reached are separate reasons. Ghost coordinates are plot-local; displayed quality/cost are never computed here.

**Wireframe.** `UI-Wireframes.html#BuildCatalogue` and `#CrewPanel`.

**Luau.** `BuildUIController.lua`, `PlacementController.lua`: local selection/form state, nudge/rotation and intent submission. Catalogue rows map to `build.select`, `build.place`, `build.move`, `build.recolour`, `build.store`, `build.theme`; see `UI-Data-Contract.md`. The engineer passes a model template and plot CFrame to the preview controller. UI has no world-authority implementation.

## Crew specification

Each crew row: portrait placeholder, fictional name, Editor/Camera Operator word, level, XP text + progress bar, assigned station/current job. Mood is hidden unless the server explicitly supplies it; no invented mood mechanic. Select → detail → hire or level preview → confirmation; assignment chooses an eligible job/station. Explain unavailable crew using an inline reason. Footer primary label changes between Hire, Level up, Assign and Unassign. Crew XP goes to its actual owner in partnership displays.

**Luau.** `CrewUIController.lua` renders the same accessible components, with `crew.hire`, `crew.level`, `crew.assign` and `crew.unassign`. Costs, XP next level and eligibility are server-supplied. No local roster mutation is used as proof of hire.

**Assets.** A01 selected catalogue thumbnails; A04 flat controls; A05 touch/generic controller/keyboard glyphs; A06 placement/cancel/error; original crew portraits and equipment thumbnails.

**Test notes.** Touch: use every placement operation without hover. Controller: focus filter → results → detail → footer; confirm focus remains after catalogue refresh. Mouse: text input must swallow R/Escape shortcuts while typing. Store busy equipment, recolour an invalid slot, and submit twice; verify readable server rejection and no local resource change.

**Open questions.** None for layout. The 3D raycast/ownership/overlap adapter and authoritative catalogue are the engineer’s integration tasks.
