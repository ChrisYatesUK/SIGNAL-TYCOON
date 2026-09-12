# 16 · First five minutes

**Intent.** Teach one action at a time and put a permanent Common Drop in the player’s collection within about two minutes. Later economy concepts stay behind their release and learning gates.

| Time target / server milestone | Visual + interaction script | Failure / re-entry | Assets |
|---|---|---|---|
| 0:00–0:30 / needsPlot | Show one reachable free plot, outline its claim plinth and display “Claim your studio.” Twelve plots are available at launch. Claim is one 48px action. Starter station appears only after confirmed ownership. | Claim raced: choose the next server-reported free plot; no fake owned state. Rejoin resumes the actual claimed plot. | Pulse mark, claim plinth, A05 tap/confirm |
| 0:30–0:45 / needsProp | Open Build with one free tutorial prop selected. Show footprint, 2-stud grid, Place/Rotate/Cancel and a short “Make it yours” caption. | Rejected placement keeps preview and explains obstruction; cancel reopens the objective. | A01 plant, A04 controls, A06 click |
| 0:45–1:00 / needsSetup | Production: choose Gaming/Comedy/Music; select starter Editor. Explain “Your Editor helps finish productions.” Preview duration and guaranteed Common. Start only with a current server setup. | Missing crew/equipment has an inline repair action; no job starts silently. | Original category icon, Remy portrait |
| 1:00–2:00 / rendering → ready | Show about a 60-second tutorial timer; working pose; one optional invitation to look around. When server marks Ready, the same button becomes Collect. Reveal the Common circle + word once on acknowledgement. | A timer at zero means checking completion until the server replies. Offline progress is restored from the saved job. No duplicate reveal on reconnect. | A06 confirmation; A07 8 particles maximum |
| 2:00–3:00 / needsUpgrade | Show one useful affordable earned upgrade with current vs next server-supplied setup values and Credit cost. Confirm → apply → before/after equipment silhouette. | Unaffordable or stale price: refresh the quote; retain Credits display until state updates. No monetisation prompt. | Original equipment tiers; A06 upgrade |
| 3:00–5:00 / needsSecondProduction → collectionSeen | Ask player to choose and start another production. Open Collection, select the first Drop, show Studio Series, permanent Common, quality and time. Finish with “Create your next Drop.” | Closing tutorial leaves one persistent HUD objective. Re-entry does not reset tutorial rewards or grant another guaranteed Common. | Original card; A04 list; A05 prompts |

**Specification.** Caption maximum two lines at 16px in a 72px HUD objective area. One focus target highlighted with a static outline; no forced camera spins, pulsing arrows or hand cursor covering the object. Each step must be completed through touch, mouse or gamepad with the same server milestone. Skip explanation/dismiss hint is allowed; required learning gates remain server-owned. Do not lock standard settings during tutorial.

**Wireframe.** `visuals/Onboarding.html` shows the five milestone panels in order. The wireframe values are timing targets, not evidence of a measured playtest.

**Luau.** `OnboardingController.lua` projects a server objective into the HUD without granting anything. Engineer supplies tutorial state, objective localisation key and action target. Highlighted world props must be resolved safely if streaming removes them; the HUD objective still works.

**Test notes.** Time at least five first-time players on a physical phone; record median and slowest time to collect. Interrupt at every milestone and resume. Complete with effects disabled, without audio, and by controller alone. Confirm market access follows tutorial + ten productions + 24 hours from v2 rather than the vague original “Day 1” copy.

**Open questions.** None blocking presentation. Exact tutorial job duration and free prop grant are engine configuration.
