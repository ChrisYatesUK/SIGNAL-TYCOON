# Signal Tycoon — M0/M1 Source Tree

Engineering-agent deliverable for milestone M0 (project setup) and M1
(playable studio loop). Generated from the v2.0 build plan.

## Layout

- `src/ReplicatedStorage/Shared/` — types, configs, remote contract (shared by server + client)
- `src/ServerScriptService/` — services, economy stubs, analytics, VPS client stub

## Building

This tree is Rojo-compatible. Run:

    rojo serve

Then connect from Roblox Studio.

## Status

- **M0 complete** — types, configs, remotes, rate limits, project skeleton
- **M1 in progress** — PlayerDataService, PlotService, ProductionService,
  ProgressionService implemented; stubs for V2+ modules present.
