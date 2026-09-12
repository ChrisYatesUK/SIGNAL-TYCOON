--!strict
-- Entry point. Creates remotes, wires services, handles joins.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteDefinitions = require(Shared:WaitForChild("Net"):WaitForChild("RemoteDefinitions"))
local RateLimits = require(Shared:WaitForChild("Net"):WaitForChild("RateLimits"))

local Services = script.Parent:WaitForChild("Services")
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local PlotService       = require(Services:WaitForChild("PlotService"))
local ProductionService = require(Services:WaitForChild("ProductionService"))

-- ── Remote creation ──────────────────────────────────────────────────────

local remotesFolder = ReplicatedStorage:FindFirstChild(RemoteDefinitions.FolderName)
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = RemoteDefinitions.FolderName
    remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(className: "RemoteEvent" | "RemoteFunction", name: string): Instance
    local existing = remotesFolder:FindFirstChild(name)
    if existing then return existing end
    local r = Instance.new(className)
    r.Name = name
    r.Parent = remotesFolder
    return r
end

local events: { [string]: RemoteEvent } = {}
for name in pairs(RemoteDefinitions.Events) do
    events[name] = ensureRemote("RemoteEvent", name) :: RemoteEvent
end
local functions: { [string]: RemoteFunction } = {}
for name in pairs(RemoteDefinitions.Functions) do
    functions[name] = ensureRemote("RemoteFunction", name) :: RemoteFunction
end

-- ── Public profile shape ─────────────────────────────────────────────────

local function toPublicProfile(profile): any
    local job = profile.activeJobId and profile.jobs[profile.activeJobId] or nil
    return {
        userId = profile.userId,
        displayName = profile.displayName,
        credits = profile.credits,
        followers = profile.followers,
        rebirthLevel = profile.rebirthLevel,
        unlocks = profile.unlocks,
        crew = profile.crew,
        placements = profile.placements,
        activeJob = job,
        tutorialState = profile.tutorialState,
        partnership = profile.partnership,
        settings = profile.settings,
    }
end

-- ── Rate limiting ────────────────────────────────────────────────────────

local buckets: { [number]: { [string]: { tokens: number, lastRefill: number } } } = {}

local function allow(player: Player, remoteName: string): boolean
    local cfg = RateLimits.PerPlayer[remoteName]
    if not cfg then return true end
    local uid = player.UserId
    buckets[uid] = buckets[uid] or {}
    local bucket = buckets[uid][remoteName]
    local now = os.clock()
    if not bucket then
        bucket = { tokens = cfg.capacity, lastRefill = now }
        buckets[uid][remoteName] = bucket
    end
    local elapsed = now - bucket.lastRefill
    bucket.tokens = math.min(cfg.capacity, bucket.tokens + elapsed * cfg.refillPerSecond)
    bucket.lastRefill = now
    if bucket.tokens < 1 then return false end
    bucket.tokens -= 1
    return true
end

-- ── Argument validation ──────────────────────────────────────────────────

local function isVector3Data(v: any): boolean
    return type(v) == "table"
       and type(v.x) == "number" and type(v.y) == "number" and type(v.z) == "number"
       and v.x == v.x and v.y == v.y and v.z == v.z
end

local function safeString(s: any, maxLen: number): string?
    if type(s) ~= "string" then return nil end
    if #s == 0 or #s > maxLen then return nil end
    return s
end

-- ── Wiring ───────────────────────────────────────────────────────────────

PlayerDataService.init()

events.RequestPlacement.OnServerEvent:Connect(function(player, catalogKey, position, rotationY)
    if not allow(player, "RequestPlacement") then return end
    local key = safeString(catalogKey, 64)
    if not key or not isVector3Data(position) or type(rotationY) ~= "number" then return end
    local ok, err = PlotService.requestPlacement(player, key, position, rotationY)
    events.ActionResult:FireClient(player, "RequestPlacement", ok, err)
end)

events.RequestMove.OnServerEvent:Connect(function(player, placementId, position, rotationY)
    if not allow(player, "RequestMove") then return end
    local pid = safeString(placementId, 64)
    if not pid or not isVector3Data(position) or type(rotationY) ~= "number" then return end
    local ok, err = PlotService.requestMove(player, pid, position, rotationY)
    events.ActionResult:FireClient(player, "RequestMove", ok, err)
end)

events.RequestStore.OnServerEvent:Connect(function(player, placementId)
    if not allow(player, "RequestStore") then return end
    local pid = safeString(placementId, 64)
    if not pid then return end
    local ok, err = PlotService.requestStore(player, pid)
    events.ActionResult:FireClient(player, "RequestStore", ok, err)
end)

events.RequestStartJob.OnServerEvent:Connect(function(player, categoryId, crewIds, placementIds)
    if not allow(player, "RequestStartJob") then return end
    local cat = safeString(categoryId, 32)
    if not cat or type(crewIds) ~= "table" or type(placementIds) ~= "table" then return end
    if #crewIds > 4 or #placementIds > 12 then return end
    for _, id in ipairs(crewIds) do
        if not safeString(id, 64) then return end
    end
    for _, id in ipairs(placementIds) do
        if not safeString(id, 64) then return end
    end
    local ok, err = ProductionService.requestStart(player, cat, crewIds, placementIds)
    events.ActionResult:FireClient(player, "RequestStartJob", ok, err)
end)

events.RequestCollectJob.OnServerEvent:Connect(function(player, jobId)
    if not allow(player, "RequestCollectJob") then return end
    local jid = safeString(jobId, 64)
    if not jid then return end
    local ok, err = ProductionService.requestCollect(player, jid)
    events.ActionResult:FireClient(player, "RequestCollectJob", ok, err)
end)

functions.GetPublicProfile.OnServerInvoke = function(player: Player)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return nil end
    return toPublicProfile(profile)
end

-- ── Join / leave ─────────────────────────────────────────────────────────

local function onPlayerAdded(player: Player)
    local ok, err = PlayerDataService.loadForPlayer(player)
    if not ok then
        events.ToastMessage:FireClient(player, "error",
            "Your data could not be loaded. Please rejoin in a minute. (" .. tostring(err) .. ")")
        return
    end

    ProductionService.reconcileOnJoin(player)

    local profile = PlayerDataService.getProfile(player)
    if profile then
        events.ProfileReplicated:FireClient(player, toPublicProfile(profile))
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, p)
end

Players.PlayerRemoving:Connect(function(player)
    buckets[player.UserId] = nil
end)

print("[Signal Tycoon] Server bootstrap complete.")
