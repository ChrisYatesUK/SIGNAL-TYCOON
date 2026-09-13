--!strict
local LocalizationService=game:GetService("LocalizationService")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local source=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UILocalization"))
local Localization={}
Localization.__index=Localization
function Localization.new()
 local fallback=Instance.new("LocalizationTable")
 fallback.SourceLocaleId="en-us"
 local entries={}
 for key,value in pairs(source) do
  table.insert(entries,{Key=key,Source=value,Values={["en-us"]=value}})
 end
 fallback:SetEntries(entries)
 return setmetatable({fallback=fallback,translator=fallback:GetTranslator("en-us"),generation=0,dead=false},Localization)
end
function Localization:T(key: string,args: {[string]:any}?): string
 local ok,value=pcall(function() return self.translator:FormatByKey(key,args or {}) end)
 if ok then return value end
 local success,result=pcall(function() return self.fallback:GetTranslator("en-us"):FormatByKey(key,args or {}) end)
 if success then return result end
 warn("Missing localisation key",key) -- Developer diagnostic, never player copy.
 return self.fallback:GetTranslator("en-us"):FormatByKey("ui.unavailable")
end
function Localization:SetLocale(locale: string,changed: ()->())
 self.generation+=1
 local generation=self.generation
 task.spawn(function()
  local ok,value=pcall(function()
   if locale=="auto" then return LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer) end
   return LocalizationService:GetTranslatorForLocaleAsync(locale)
  end)
  if self.dead or generation~=self.generation then return end
  self.translator=if ok then value else self.fallback:GetTranslator("en-us")
  changed()
 end)
end
function Localization:Destroy()
 self.dead=true
 self.generation+=1
 self.fallback:Destroy()
end
return Localization
