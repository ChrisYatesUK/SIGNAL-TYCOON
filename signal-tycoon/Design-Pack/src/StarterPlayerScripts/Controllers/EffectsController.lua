--!strict
local CollectionService=game:GetService("CollectionService")
local GuiService=game:GetService("GuiService")
local SoundService=game:GetService("SoundService")
local Scope=require(script.Parent.Scope)
local Effects={}
Effects.__index=Effects
function Effects.new()
 local self:any=setmetatable({scope=Scope.new(),requested=false,originals={},listeners={},sounds={},dead=false},Effects)
 self.group=Instance.new("SoundGroup")
 self.group.Name="PulseUISFX"
 self.group.Parent=SoundService
 self.scope:Add(self.group)
 local function register(obj: Instance)
  if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Light") then
   if self.originals[obj]~=nil then return end
   self.originals[obj]=(obj :: any).Enabled
   self.listeners[obj]=obj.Destroying:Connect(function()
    self.originals[obj]=nil
    if self.listeners[obj] then self.listeners[obj]:Disconnect(); self.listeners[obj]=nil end
   end)
   self:Apply()
  end
 end
 self.scope:Add(CollectionService:GetInstanceAddedSignal("PulseOptionalEffect"):Connect(register))
 self.scope:Add(CollectionService:GetInstanceRemovedSignal("PulseOptionalEffect"):Connect(function(obj)
  local value=self.originals[obj]
  if value~=nil then (obj :: any).Enabled=value end
  self.originals[obj]=nil
  if self.listeners[obj] then self.listeners[obj]:Disconnect(); self.listeners[obj]=nil end
 end))
 self.scope:Add(GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function() self:Apply() end))
 for _,obj in CollectionService:GetTagged("PulseOptionalEffect") do register(obj) end
 return self
end
function Effects:IsReduced(): boolean
 return self.requested or GuiService.ReducedMotionEnabled
end
function Effects:Apply()
 for obj,original in pairs(self.originals) do
  (obj :: any).Enabled=original and not self:IsReduced()
  if self:IsReduced() and obj:IsA("ParticleEmitter") then obj:Clear() end
 end
end
function Effects:Set(reduced: boolean,volume: number)
 self.requested=reduced
 self.group.Volume=math.clamp(volume,0,1)
 self:Apply()
end
-- All one-shot bursts MUST go through here: Enabled=false does not block :Emit().
function Effects:Emit(emitter: ParticleEmitter,count: number)
 if not self:IsReduced() then emitter:Emit(math.clamp(count,0,12)) end
end
function Effects:Play(assetId: string)
 if self.dead or string.find(assetId,"PENDING",1,true) then return end
 local sound=Instance.new("Sound")
 sound.SoundId=assetId;sound.SoundGroup=self.group;sound.Volume=0.35;sound.Parent=SoundService
 local scope=Scope.new();self.sounds[sound]=scope
 local function finish()
  if not self.sounds[sound] then return end
  self.sounds[sound]=nil;scope:Destroy();sound:Destroy()
 end
 scope:Add(sound.Ended:Connect(finish))
 scope:Add(sound.Destroying:Connect(function()
  self.sounds[sound]=nil;scope:Destroy()
 end))
 sound:Play()
 task.delay(5,finish)
end
function Effects:Destroy()
 if self.dead then return end
 self.dead=true
 for sound,scope in pairs(self.sounds) do scope:Destroy();sound:Destroy() end
 self.sounds={}
 for obj,value in pairs(self.originals) do (obj :: any).Enabled=value end
 for _,connection in pairs(self.listeners) do connection:Disconnect() end
 self.originals={}; self.listeners={}
 self.scope:Destroy()
end
return Effects
