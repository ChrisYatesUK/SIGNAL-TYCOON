--!strict
-- Binder for an existing world SurfaceGui TextLabel. Data is already server-projected.
local Scope=require(script.Parent.Scope)
local WorldDisplay={}
function WorldDisplay.Bind(label: TextLabel,subscribe: ((string)->())->RBXScriptConnection)
 local scope=Scope.new()
 scope:Add(subscribe(function(filteredDisplay: string) label.Text=filteredDisplay end))
 scope:Add(label.Destroying:Connect(function() scope:Destroy() end))
 return scope
end
return WorldDisplay
