--!strict
-- The engineer supplies the authoritative tutorial milestone's localisation text.
-- This only updates a HUD objective; it cannot advance or reward the tutorial.
local Scope=require(script.Parent.Scope)
local Onboarding={}
function Onboarding.Bind(ui: any,subscribe: ((any)->())->RBXScriptConnection)
 local scope=Scope.new()
 scope:Add(subscribe(function(objective)
  if ui.dead then return end
  ui.objective=objective
  ui:Render()
 end))
 return scope -- caller must Destroy this scope with its UI owner
end
return Onboarding
