--!strict
-- Shared client renderer. Server supplies bounded display projections, not executable code.
-- All economy actions are RemoteEvent intents; authoritative snapshots drive outcomes.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local GuiService=game:GetService("GuiService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local T=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Tokens"))
local Assets=require(ReplicatedStorage.Shared.UIAssets)
local Scope=require(script.Parent.Scope)
local Localization=require(script.Parent.Localization)
local Effects=require(script.Parent.EffectsController)
local UI={}
UI.__index=UI

local function create(class: string,parent: Instance?,props: {[string]:any}): any
 local obj:any=Instance.new(class)
 if parent and obj:IsA("GuiObject") then obj.LayoutOrder=#parent:GetChildren()+1 end
 for key,value in pairs(props) do obj[key]=value end
 obj.Parent=parent
 return obj
end
local function corner(obj: GuiObject)
 create("UICorner",obj,{CornerRadius=UDim.new(0,8)})
end

function UI.new(definitions: {any},send: (any)->())
 local self:any=setmetatable({scope=Scope.new(),paint=Scope.new(),locale=Localization.new(),effects=Effects.new(),
  definitions={},send=send,screen="HUD",snapshot=nil,drafts={},pending={},status=nil,confirm=nil,
  buttons={},timers={},dead=false,device="keyboard",settings={reducedEffects=false,volume=1,locale="auto"}},UI)
 self.gui={}
 for _,def in definitions do
  self.definitions[def.name]=def
  local gui=create("ScreenGui",Players.LocalPlayer:WaitForChild("PlayerGui"),{
   Name=def.name,ResetOnSpawn=false,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,
   ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=20,Enabled=false,
  })
  self.gui[def.name]=gui;self.scope:Add(gui)
  self.scope:Add(gui.Destroying:Connect(function() if not self.dead then self:Destroy() end end))
 end
 self.scope:Add(UserInputService.LastInputTypeChanged:Connect(function(kind) self:Device(kind) end))
 local cameraConnection: RBXScriptConnection?=nil
 local function bindCamera()
  if cameraConnection then cameraConnection:Disconnect() end
  local camera=Workspace.CurrentCamera
  if camera then cameraConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() self:Render() end) end
 end
 bindCamera()
 self.scope:Add(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))
 self.scope:Add(function() if cameraConnection then cameraConnection:Disconnect() end end)
 self.scope:Add(UserInputService.InputBegan:Connect(function(input,processed)
  if processed or UserInputService:GetFocusedTextBox() then return end
  if input.KeyCode==Enum.KeyCode.ButtonB or input.KeyCode==Enum.KeyCode.Escape then self:Back()
  elseif input.KeyCode==Enum.KeyCode.ButtonSelect then
   GuiService.SelectedObject=self.buttons[1]
  end
 end))
 local elapsed=0
 self.scope:Add(RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt
  if elapsed<0.25 then return end
  elapsed=0
  for _,timer in self.timers do
   local remaining=math.max(0,math.ceil(timer.deadline-Workspace:GetServerTimeNow()))
   timer.label.Text=if remaining==0 then self.locale:T("timer.checking") else self.locale:T("timer.remaining",{minutes=math.floor(remaining/60),seconds=string.format("%02d",remaining%60)})
  end
 end))
 self:Device(UserInputService:GetLastInputType())
 self.locale:SetLocale("auto",function() if not self.dead then self:Render() end end)
 return self
end

function UI:Text(value: any): string
 if not value then return "" end
 return self.locale:T(value.key,value.args)
end
function UI:Device(kind: Enum.UserInputType)
 local name=kind.Name
 if string.find(name,"Gamepad") and UserInputService.GamepadEnabled then self.device="gamepad"
 elseif kind==Enum.UserInputType.Touch and UserInputService.TouchEnabled then self.device="touch"
 elseif UserInputService.KeyboardEnabled then self.device="keyboard"
 elseif UserInputService.TouchEnabled then self.device="touch"
 else self.device="gamepad" end
 if not UserInputService:GetFocusedTextBox() then self:Render() end
end
function UI:Label(parent: Instance,text: string,height: number,bold: boolean?): TextLabel
 return create("TextLabel",parent,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,height),
  Text=text,TextColor3=T.Ink,Font=if bold then T.Bold else T.Body,TextSize=16,
  TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
  AutoLocalize=false,RichText=false,AutomaticSize=Enum.AutomaticSize.Y})
end
function UI:Button(parent: Instance,id: string,text: string,callback: ()->(),enabled: boolean?): TextButton
 local active=enabled~=false
 local b:TextButton=create("TextButton",parent,{Name=id,Size=UDim2.new(1,0,0,48),
  BackgroundColor3=if active then T.Primary else T.Raised,TextColor3=T.Ink,
  Font=T.Bold,TextSize=16,Text=text,TextWrapped=true,AutoLocalize=false,RichText=false,
  Selectable=true,AutoButtonColor=false})
 corner(b)
 local outline=create("UIStroke",b,{Thickness=3,Color=T.Ink,Enabled=false})
 self.paint:Add(b.SelectionGained:Connect(function()
  outline.Enabled=true
  local scroller=b:FindFirstAncestorWhichIsA("ScrollingFrame")
  if scroller then
   local deltaTop=b.AbsolutePosition.Y-scroller.AbsolutePosition.Y
   local deltaBottom=deltaTop+b.AbsoluteSize.Y-scroller.AbsoluteSize.Y
   if deltaTop<0 then scroller.CanvasPosition+=Vector2.new(0,deltaTop)
   elseif deltaBottom>0 then scroller.CanvasPosition+=Vector2.new(0,deltaBottom) end
  end
 end))
 self.paint:Add(b.SelectionLost:Connect(function() outline.Enabled=false end))
 self.paint:Add(b.Activated:Connect(function() if active then callback() end end))
 table.insert(self.buttons,b)
 return b
end
function UI:Open(name: string)
 if not self.definitions[name] then return end
 if self.screen=="BuildCatalogue" and name~="BuildCatalogue" and self.placement then self.placement:Cancel() end
 self.confirm=nil;self.status=nil;self.screen=name;self:Render()
end
function UI:Back()
 if self.confirm then self.confirm=nil;self:Render();return end
 self:Open("HUD")
end
function UI:SetSnapshot(snapshot: any)
 if self.snapshot and snapshot.revision<=self.snapshot.revision then return end
 if UserInputService:GetFocusedTextBox() then self.deferred=snapshot;return end
 self.snapshot=snapshot
 self.confirm=nil -- any authoritative revision invalidates a local review
 if not self.preferenceDirty and snapshot.settings then
  local localeChanged=self.settings.locale~=snapshot.settings.locale
  self.settings=table.clone(snapshot.settings)
  self.effects:Set(self.settings.reducedEffects,self.settings.volume)
  if localeChanged then self.locale:SetLocale(self.settings.locale,function() if not self.dead then self:Render() end end) end
 end
 self:Render()
end
function UI:Result(result: any)
 if not self.pending[result.requestId] then return end
 self.pending[result.requestId]=nil
 -- `ok` only means the server accepted/rejected this request; snapshot proves inventory changes.
 self.status=result.message or {key="ui.refreshing"}
 if result.cue and Assets.Sounds[result.cue] then self.effects:Play(Assets.Sounds[result.cue]) end
 self:Render()
end
function UI:Dispatch(action: string,payload: any?)
 local def=self.definitions[self.screen]
 if not def.actions[action] then return end
 if next(self.pending)~=nil then self.status={key="ui.pending"};self:Render();return end
 local id=HttpService:GenerateGUID(false)
 local view=if self.snapshot then self.snapshot.screens[self.screen] else nil
 self.pending[id]=true
 self.status={key="ui.pending"}
 self.send({requestId=id,screen=self.screen,action=action,
  revision=if view then view.revision else 0,payload=payload or {},draft=table.clone(self.drafts[self.screen] or {})})
 self:Render()
 task.delay(12,function()
  if self.dead or not self.pending[id] then return end
  -- Keep lock until reconciliation/result. Never automatically repeat an irreversible intent.
  self.status={key="ui.unknown"};self:Render()
 end)
end
function UI:Do(row: any)
 if row.action=="ui.report" then
  self.drafts.ReportDialog=table.clone(row.payload or {})
  self:Open("ReportDialog");return
 end
 if row.bindings then
  local draft=self.drafts[self.screen] or {}
  for key,value in pairs(row.bindings) do
   if draft[key]~=value then self.status={key="ui.quoteChanged"};self:Render();return end
  end
 end
 if self.placement then
  local localActions={
   ["build.rotate"]=function() self.placement:Rotate() end,
   ["build.north"]=function() self.placement:Nudge(0,-1) end,
   ["build.south"]=function() self.placement:Nudge(0,1) end,
   ["build.west"]=function() self.placement:Nudge(-1,0) end,
   ["build.east"]=function() self.placement:Nudge(1,0) end,
   ["build.cancelPreview"]=function() self.placement:Cancel() end,
   ["build.submitPreview"]=function() self.placement:Submit() end,
  }
  if localActions[row.action] then localActions[row.action]();return end
 end
 if row.notBefore and Workspace:GetServerTimeNow()<row.notBefore then
  self.status={key="ui.cooling"};self:Render();return
 end
 if row.action=="settings.toggle" then
  self.settings.reducedEffects=not self.settings.reducedEffects;self.preferenceDirty=true
  self.effects:Set(self.settings.reducedEffects,self.settings.volume);self:Render();return
 elseif row.action=="settings.quieter" or row.action=="settings.louder" then
  self.settings.volume=math.clamp(self.settings.volume+(if row.action=="settings.louder" then 0.1 else -0.1),0,1)
  self.preferenceDirty=true;self.effects:Set(self.settings.reducedEffects,self.settings.volume);self:Render();return
 elseif row.action=="settings.save" then
  local draft=self.drafts.Settings or {}
  self.settings.locale=draft.locale or self.settings.locale
  self.locale:SetLocale(self.settings.locale,function() if not self.dead then self:Render() end end)
  self:Dispatch(row.action,table.clone(self.settings));return
 end
 if row.confirm then self.confirm=row;self:Render();return end
 self:Dispatch(row.action,row.payload)
end
function UI:Row(parent: Instance,row: any)
 local draft=self.drafts[self.screen]
 local holder=create("Frame",parent,{Name=row.id,Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
 create("UIListLayout",holder,{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
 if row.kind=="action" then
  self:Button(holder,row.id,self:Text(row.text),function() self:Do(row) end,row.enabled)
 elseif row.kind=="choice" or row.kind=="multiChoice" then
  self:Label(holder,self:Text(row.text),24,true)
  if draft[row.field]==nil then draft[row.field]=row.value end
  for _,option in row.options or {} do
   local selected=if row.kind=="multiChoice" then table.find(draft[row.field] or {},option.id)~=nil else draft[row.field]==option.id
   local label=self:Text(option.text)
   if selected then label=self.locale:T("ui.selected",{label=label}) end
   self:Button(holder,row.id.."_"..option.id,label,function()
    if row.kind=="multiChoice" then
     local values=table.clone(draft[row.field] or {})
     local index=table.find(values,option.id)
     if index then table.remove(values,index)
     elseif #values<4 then table.insert(values,option.id) end
     draft[row.field]=values
    else draft[row.field]=option.id end
    self.confirm=nil
    -- Selection is draft-only. Quote/Refresh action requests a new server projection.
    self:Render()
   end,true)
  end
 elseif row.kind=="input" then
  self:Label(holder,self:Text(row.text),24,true)
  local box:TextBox=create("TextBox",holder,{Name=row.id,Size=UDim2.new(1,0,0,72),
   Text=tostring(draft[row.field] or row.value or ""),Font=T.Body,TextSize=16,
   TextColor3=T.Ink,BackgroundColor3=T.Raised,ClearTextOnFocus=false,
   TextWrapped=true,MultiLine=true,AutoLocalize=false,Selectable=true})
  corner(box);table.insert(self.buttons,box)
  local focus=create("UIStroke",box,{Thickness=3,Color=T.Ink,Enabled=false})
  self.paint:Add(box.SelectionGained:Connect(function() focus.Enabled=true end))
  self.paint:Add(box.SelectionLost:Connect(function() focus.Enabled=false end))
  self.paint:Add(box:GetPropertyChangedSignal("Text"):Connect(function()
   -- 200 Unicode codepoints, not 200 potentially split UTF-8 bytes.
   local offset=utf8.offset(box.Text,201)
   if offset then box.Text=string.sub(box.Text,1,offset-1) end
   draft[row.field]=box.Text
  end))
  self.paint:Add(box.FocusLost:Connect(function()
   if self.deferred then local latest=self.deferred;self.deferred=nil;self:SetSnapshot(latest) end
  end))
 else
  self:Label(holder,self:Text(row.text),28,true)
  if row.rarity and T.Rarity[row.rarity] then
   local rarity=T.Rarity[row.rarity]
   local band=create("Frame",holder,{Size=UDim2.new(1,0,0,36),BackgroundColor3=T.Surface})
   local id=Assets.Rarity[rarity.shape]
   if id and not string.find(id,"PENDING",1,true) then
    create("ImageLabel",band,{Size=UDim2.fromOffset(24,24),Position=UDim2.fromOffset(0,6),BackgroundTransparency=1,Image=id,ImageColor3=rarity.colour})
   else
    create("TextLabel",band,{Size=UDim2.fromOffset(24,36),BackgroundTransparency=1,Text=rarity.fallback,TextSize=22,TextColor3=rarity.colour,Font=Enum.Font.SourceSans,AutoLocalize=false})
   end
   local label=self:Label(band,self.locale:T(rarity.key),36,true)
   label.Position=UDim2.fromOffset(32,0);label.Size=UDim2.new(1,-32,0,36)
  end
  if row.kind=="progress" then
   local current=row.current or 0;local maximum=row.maximum or 0
   self:Label(holder,self.locale:T("ui.progress",{current=current,maximum=maximum}),24,false)
   local track=create("Frame",holder,{Size=UDim2.new(1,0,0,8),BackgroundColor3=T.Raised})
   create("Frame",track,{Size=UDim2.fromScale(if maximum>0 then math.clamp(current/maximum,0,1) else 0,1),BackgroundColor3=T.Brand})
  elseif row.kind=="timer" and row.deadline then
   local label=self:Label(holder,"",28,false)
   table.insert(self.timers,{label=label,deadline=row.deadline})
  end
 end
 if row.detail then self:Label(holder,self:Text(row.detail),28,false) end
 if row.enabled==false then self:Label(holder,self:Text(row.reason or {key="ui.unavailable"}),28,false) end
end

function UI:Render()
 if self.dead then return end
 local selected=GuiService.SelectedObject
 local selectedName=if selected then selected.Name else nil
 local savedScroll=self.scroller and self.scroller.CanvasPosition or Vector2.zero
 self.scroller=nil
 GuiService.SelectedObject=nil
 self.paint:Clean();self.buttons={};self.timers={}
 for _,gui in pairs(self.gui) do gui.Enabled=false end
 local gui=self.gui[self.screen]
 if not gui then return end
 gui.Enabled=true
 local root=create("Frame",gui,{Name="Root",Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
 self.paint:Add(root)
 self.drafts[self.screen]=self.drafts[self.screen] or {}
 if self.screen=="HUD" then self:HUD(root)
 else self:Panel(root,savedScroll) end
 for i,b in self.buttons do
  local previous=self.buttons[if i==1 then #self.buttons else i-1]
  local following=self.buttons[if i==#self.buttons then 1 else i+1]
  b.NextSelectionUp=previous;b.NextSelectionDown=following
  b.NextSelectionLeft=previous;b.NextSelectionRight=following
  b.SelectionOrder=i
 end
 if self.device=="gamepad" then
  local target=self.buttons[1]
  for _,b in self.buttons do if b.Name==selectedName then target=b end end
  if self.confirm then for _,b in self.buttons do if b.Name=="cancelReview" then target=b end end end
  GuiService.SelectedObject=target
 end
end

function UI:HUD(root: Frame)
 local width=if Workspace.CurrentCamera then Workspace.CurrentCamera.ViewportSize.X else 360
 local desktop=width>=900
 local top=create("Frame",root,{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,48),BackgroundColor3=T.Surface})
 corner(top)
 local state=self.snapshot and self.snapshot.hud
 local balance=self:Label(top,if state then self.locale:T("hud.balances",{credits=state.credits,followers=state.followers}) else self.locale:T("ui.loading"),48,true)
 balance.Size=UDim2.new(1,-60,0,48);balance.Position=UDim2.fromOffset(8,0)
 local settings=self:Button(top,"navSettings",self.locale:T("nav.settings"),function() self:Open("Settings") end)
 settings.Size=UDim2.fromOffset(60,48);settings.Position=UDim2.new(1,-60,0,0);settings.TextSize=14
 local timer=self:Button(root,"navProduction",self.locale:T(if state then "job."..state.phase else "ui.loading"),function() self:Open("ProductionPanel") end)
 timer.Position=UDim2.fromOffset(12,64);timer.Size=UDim2.new(1,-24,0,48)
 if state and state.phase=="rendering" and state.completesAt then table.insert(self.timers,{label=timer,deadline=state.completesAt}) end
 local partner=self:Button(root,"navPartner",self.locale:T("hud.partner",{name=if state and state.partner then state.partner else self.locale:T("partner.solo")}),function() self:Open("PartnershipPanel") end)
 partner.Position=UDim2.fromOffset(12,120);partner.Size=UDim2.new(1,-24,0,48)
 if self.objective then
  local objective=self:Label(root,self:Text(self.objective),64,false)
  objective.Position=UDim2.fromOffset(12,176);objective.Size=UDim2.new(1,-24,0,64)
 end
 local nav={{"BuildCatalogue","nav.build"},{"CrewPanel","nav.crew"},{"ProductionPanel","nav.produce"},{"CollectionPanel","nav.collection"},{"ChartBoard","nav.chart"},{"MarketplaceHub","nav.market"}}
 local columns=if desktop then 6 else 3
 local reserve=if self.device=="touch" then 100 else 12
 for i,item in nav do
  local column=(i-1)%columns;local row=math.floor((i-1)/columns)
  local b=self:Button(root,"nav"..item[1],self.locale:T(item[2]),function() self:Open(item[1]) end)
  b.Size=UDim2.new(1/columns,-(24+(columns-1)*8)/columns,0,48)
  b.Position=UDim2.new(column/columns,12+column*8/columns,1,-reserve-(if desktop then 48 else 104)+row*56)
 end
end

function UI:Panel(root: Frame,savedScroll: Vector2)
 local veil=create("TextButton",root,{Size=UDim2.fromScale(1,1),Text="",AutoButtonColor=false,BackgroundColor3=T.Ink,BackgroundTransparency=0.35,Selectable=false,Modal=true})
 local width=if Workspace.CurrentCamera then Workspace.CurrentCamera.ViewportSize.X else 360
 local panel=create("Frame",veil,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-24,1,-16),BackgroundColor3=T.Surface})
 create("UISizeConstraint",panel,{MaxSize=Vector2.new(720,100000)})
 if self.screen=="BuildCatalogue" and width>=900 then
  panel.AnchorPoint=Vector2.new(0,0.5);panel.Position=UDim2.new(0,12,0.5,0);panel.Size=UDim2.new(0,360,1,-16)
 end
 corner(panel)
 local title=self:Label(panel,self.locale:T("screen."..self.screen),48,true)
 title.Position=UDim2.fromOffset(12,4);title.Size=UDim2.new(1,-116,0,48);title.TextSize=20
 local close=self:Button(panel,"close",self.locale:T("ui.close"),function() self:Back() end)
 close.Size=UDim2.fromOffset(88,48);close.Position=UDim2.new(1,-100,0,4)
 local body=create("ScrollingFrame",panel,{Position=UDim2.fromOffset(12,60),Size=UDim2.new(1,-24,1,-180),BackgroundTransparency=1,BorderSizePixel=0,
  ScrollBarThickness=4,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y})
 self.scroller=body
 create("UIListLayout",body,{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder})
 local view=self.snapshot and self.snapshot.screens[self.screen]
 if self.confirm then
  self:Label(body,self:Text(self.confirm.confirm),72,true)
  self:Button(body,"cancelReview",self.locale:T("ui.cancel"),function() self.confirm=nil;self:Render() end)
  local row=self.confirm
  self:Button(body,"confirmReview",self.locale:T("ui.confirm"),function()
   self.confirm=nil;self:Dispatch(row.action,row.payload)
  end,true)
 elseif view then
  for _,row in view.rows do self:Row(body,row) end
  if self.screen=="Settings" then
   self:Label(body,self.locale:T("settings.summary",{effects=self.locale:T(if self.effects:IsReduced() then "settings.reduced" else "settings.full"),volume=math.round(self.settings.volume*100)}),48,true)
  end
 else self:Label(body,self.locale:T("ui.loading"),48,false) end
 body.CanvasPosition=savedScroll
 local status=self:Label(panel,self:Text(self.status),44,false)
 status.TextSize=14;status.Position=UDim2.new(0,12,1,-116);status.Size=UDim2.new(1,-24,0,44)
 if view and view.footer and not self.confirm then
  local row=view.footer
  local footer=self:Button(panel,"footer",self:Text(row.text),function() self:Do(row) end,row.enabled~=false and next(self.pending)==nil)
  footer.Size=UDim2.new(1,-24,0,48);footer.Position=UDim2.new(0,12,1,-68)
 end
 local prompt=self:Label(panel,self.locale:T("prompt."..self.device),16,false)
 prompt.TextSize=14;prompt.Position=UDim2.new(0,12,1,-18);prompt.Size=UDim2.new(1,-24,0,16)
 local icon=Assets.Prompts[self.device]
 if icon and not string.find(icon,"PENDING",1,true) then
  create("ImageLabel",panel,{Size=UDim2.fromOffset(16,16),Position=UDim2.new(1,-28,1,-18),BackgroundTransparency=1,Image=icon})
 end
end
function UI:Destroy()
 if self.dead then return end
 self.dead=true
 if self.placement then self.placement:Destroy() end
 GuiService.SelectedObject=nil
 self.paint:Destroy();self.scope:Destroy();self.locale:Destroy();self.effects:Destroy()
end
return UI
