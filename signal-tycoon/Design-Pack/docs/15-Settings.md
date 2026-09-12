# 15 · Settings

**Intent.** Make comfort and control immediate. Settings is reachable in one tap from HUD and retains readable controls across touch, mouse and gamepad.

**Specification.** Sections: Reduced effects toggle with explanation; Sound Effects volume with numeric percentage and −/+ 10% buttons; language picker; Blocked players with explicit Unblock actions. Targets ≥48px. A slider may be added using A04, but the numeric stepper is the required accessible alternative. Only reviewed supported locales are listed; English source ships with the pack, so do not show fake selectable translations. “Use Roblox language” maps through LocalizationService with English source fallback.

**Behaviour.** Reduced effects applies immediately to local particles, optional lights and authored rapid motion; persistence emits a settings intent and can show save failure without undoing the local comfort choice. Effective reduced effects is the in-game choice OR Roblox’s ReducedMotionEnabled. Sound volume adjusts only the experience UI SFX SoundGroup, never other players' audio or platform settings. Locale changes refresh every visible label and preserve focus/form drafts. A late translator request cannot overwrite a newer locale selection. Block list updates only after acknowledged server state.

**States.** Loading saved preferences, ready, local preference applied/save pending, save unavailable, translator loading/source fallback, block update pending. English fallback comes from the localisation table module, never text literals scattered through controllers.

**Wireframe.** `UI-Wireframes.html#Settings`.

**Luau.** `SettingsUIController.lua`, `Localization.lua`, `EffectsController.lua`. Local comfort preferences are allowed client UI state; persistence uses `settings.save`. Locale is not written to read-only RobloxLocaleId. `CollectionService` tags optional authored effects as `PulseOptionalEffect`; all descendants registered after streaming are also handled. Do not tag unrelated gameplay visibility objects.

**Assets.** A04 flat check/slider controls; A05 prompts; five selected A06 interface cues. No background music or custom font assets.

**Test notes.** Toggle effects while particles exist, then stream new effects in; both must remain disabled. Re-enable restores originally enabled emitters/lights only. Change locale quickly, unplug gamepad, reopen after respawn, and test SFX at 0%. Gamepad can adjust volume without dragging.

**Open questions.** Additional locales need translation review; no blocker for the English-source implementation.
