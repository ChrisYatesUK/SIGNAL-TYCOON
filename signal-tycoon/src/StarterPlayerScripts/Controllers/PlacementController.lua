--!strict
-- UI preview only. The engineer supplies template, plot pivot and server permission.
-- Coordinates sent to the server are untrusted intent, never authoritative placement.
local Workspace=game:GetService("Workspace")
local UserInputService=game:GetService("UserInputService")
local Scope=require(script.Parent.Scope)
local Placement={}
Placement.__index=Placement
function Placement.new(send: (string,{[string]:any})->())
 return setmetatable({scope=Scope.new(),send=send,x=0,z=0,yaw=0,ghost=nil,plot=CFrame.new(),catalogueId="",placementId=nil},Placement)
end
function Placement:Begin(template: Model,plot: CFrame,catalogueId: string,placementId: string?)
 self:Cancel()
 self.plot=plot;self.catalogueId=catalogueId;self.placementId=placementId
 self.x=0;self.z=0;self.yaw=0
 local ghost=template:Clone()
 for _,obj in ghost:GetDescendants() do
  if obj:IsA("BaseScript") then obj:Destroy()
  elseif obj:IsA("BasePart") then
   obj.Anchored=true;obj.CanCollide=false;obj.CanTouch=false;obj.CanQuery=false
   obj.Transparency=math.max(obj.Transparency,0.45)
  end
 end
 ghost.Name="PulsePlacementPreview";ghost.Parent=Workspace
 self.ghost=ghost
 self.scope:Add(ghost)
 self.scope:Add(UserInputService.InputBegan:Connect(function(input,processed)
  if processed or UserInputService:GetFocusedTextBox() then return end
  if input.KeyCode==Enum.KeyCode.R then self:Rotate()
  elseif input.KeyCode==Enum.KeyCode.Escape then self:Cancel() end
 end))
 self:Update()
end
function Placement:Update()
 if self.ghost then self.ghost:PivotTo(self.plot*CFrame.new(self.x,0,self.z)*CFrame.Angles(0,math.rad(self.yaw),0)) end
end
function Placement:SetPoint(localPosition: Vector3)
 self.x=math.round(localPosition.X/2)*2;self.z=math.round(localPosition.Z/2)*2;self:Update()
end
function Placement:Nudge(x: number,z: number)
 self.x+=math.clamp(x,-1,1)*2;self.z+=math.clamp(z,-1,1)*2;self:Update()
end
function Placement:Rotate()
 self.yaw=(self.yaw+90)%360;self:Update()
end
function Placement:Submit()
 if not self.ghost then return end
 self.send(if self.placementId then "build.move" else "build.place",{
  catalogueId=self.catalogueId,placementId=self.placementId,x=self.x,z=self.z,yaw=self.yaw,
 })
 -- Keep preview until state acknowledgement. Rejection can then preserve the draft.
end
function Placement:Cancel()
 self.scope:Clean();self.ghost=nil
end
function Placement:Destroy()
 self:Cancel();self.scope:Destroy()
end
return Placement
