--!strict
-- Adapter proposal: engineer binds these RemoteEvents to existing RemoteDefinitions.
-- No RemoteEvent is created here, and no services or state are implemented.
return table.freeze({ Folder = "UIRemotes", Action = "UIAction", State = "UIState", Result = "UIResult" })
