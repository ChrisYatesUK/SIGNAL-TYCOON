--!strict
-- Install as a LocalScript under StarterPlayerScripts; Controllers are ModuleScripts.
-- Set Preview=true ATTRIBUTE on this LocalScript for a read-only design preview.
-- Live mode expects existing server RemoteEvents and never creates them locally.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local Shared=ReplicatedStorage:WaitForChild("Shared")
local Controllers=script.Parent:WaitForChild("Controllers")
local Runtime=require(Controllers.UIRuntime)
local Scope=require(Controllers.Scope)
local Remotes=require(Shared.UIRemoteDefinitions)
local Preview=require(Shared.UIPreview)
local definitions={}
for _,name in {"HUDController","BuildUIController","CrewUIController","ProductionController","CollectionUIController","ChartUIController","PartnershipUIController","MarketplaceUIController","ModerationUIController","SettingsUIController"} do
 table.insert(definitions,require(Controllers:WaitForChild(name)))
end
local scope=Scope.new()
local ui:any
local actionRemote: RemoteEvent?=nil
local preview=script:GetAttribute("Preview")==true
ui=Runtime.new(definitions,function(intent: any)
 if preview then
  task.defer(function() if not ui.dead then ui:Result({requestId=intent.requestId,ok=false,message={key="preview.only"}}) end end)
 elseif actionRemote then actionRemote:FireServer(intent)
 else task.defer(function() if not ui.dead then ui:Result({requestId=intent.requestId,ok=false,message={key="ui.offline"}}) end end) end
end)
scope:Add(function() ui:Destroy() end)
scope:Add(script.Destroying:Connect(function() scope:Destroy() end))
if preview then
 ui:SetSnapshot(Preview.Make(Workspace:GetServerTimeNow()))
 ui.status={key="preview.only"}
else
 local bound=false
 local function bind()
  if bound then return end
  local folder=ReplicatedStorage:FindFirstChild(Remotes.Folder)
  if not folder then return end
  local action=folder:FindFirstChild(Remotes.Action)
  local state=folder:FindFirstChild(Remotes.State)
  local result=folder:FindFirstChild(Remotes.Result)
  if not (action and action:IsA("RemoteEvent") and state and state:IsA("RemoteEvent") and result and result:IsA("RemoteEvent")) then return end
  bound=true;actionRemote=action
  scope:Add(state.OnClientEvent:Connect(function(snapshot) ui:SetSnapshot(snapshot) end))
  scope:Add(result.OnClientEvent:Connect(function(response) ui:Result(response) end))
  -- Subscribe before querying so an immediate snapshot cannot be missed.
  action:FireServer({action="ui.subscribe"})
 end
 scope:Add(ReplicatedStorage.DescendantAdded:Connect(bind));bind()
end
-- Placement integration, once your local selection adapter resolves a model and plot:
-- local Placement=require(Controllers.PlacementController)
-- ui.placement=Placement.new(function(action,payload) ui:Dispatch(action,payload) end)
-- scope:Add(function() ui.placement:Destroy() end)
-- ui.placement:Begin(template,plotCFrame,catalogueId,ownedPlacementId)
-- On server placement acknowledgement: ui.placement:Cancel()
-- On leaving build mode, also cancel the local preview.
