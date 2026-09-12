# ScreenGui installation

`UIBootstrap.client.lua` creates these ten ScreenGuis in PlayerGui, using the same names as the supplied StarterGui layout:
HUD, BuildCatalogue, CrewPanel, ProductionPanel, CollectionPanel, ChartBoard, PartnershipPanel, MarketplaceHub, ReportDialog, Settings.

Do not also create duplicate enabled copies in StarterGui. If your workflow requires authored StarterGui templates, create empty disabled ScreenGuis with these names, adapt the runtime to clone/use those templates, and retain ResetOnSpawn=false. The provided code-first route is sufficient to run the design preview without authoring instances by hand.

ModuleScript files ending `.lua` are not runnable LocalScripts. Only `UIBootstrap.client.lua` is a LocalScript. The preview requires the Shared modules and Controllers folders at the exact locations specified in README.
