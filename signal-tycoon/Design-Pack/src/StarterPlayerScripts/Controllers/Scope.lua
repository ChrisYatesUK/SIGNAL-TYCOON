--!strict
local Scope = {}
Scope.__index = Scope
function Scope.new()
 return setmetatable({items={} :: {any}, dead=false},Scope)
end
function Scope:Add(item: any): any
 if self.dead then
  if typeof(item)=="RBXScriptConnection" then item:Disconnect()
  elseif typeof(item)=="Instance" then item:Destroy()
  elseif type(item)=="function" then item() end
 else table.insert(self.items,item) end
 return item
end
function Scope:Clean()
 local old=self.items
 self.items={}
 for i=#old,1,-1 do
  local item=old[i]
  if typeof(item)=="RBXScriptConnection" then item:Disconnect()
  elseif typeof(item)=="Instance" then item:Destroy()
  elseif type(item)=="function" then item() end
 end
end
function Scope:Destroy()
 if self.dead then return end
 self.dead=true
 self:Clean()
end
return Scope
