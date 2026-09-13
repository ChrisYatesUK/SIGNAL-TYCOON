--!strict
-- Three-remote adapter over the v2 services. Replaces the named-remote model
-- with UIAction / UIState / UIResult to match UIRemoteDefinitions.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimits = require(Shared:WaitForChild("Net"):WaitForChild("RateLimits"))

local Services = ServerScriptService:WaitForChild("Services")
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local PlotService       = require(Services:WaitForChild("PlotService"))
local ProductionService = require(Services:WaitForChild("ProductionService"))
local TradingGate       = require(Services:WaitForChild("TradingGate"))
local UIProjection      = require(Services:WaitForChild("UIProjectionService"))

-- ── Remote wiring ────────────────────────────────────────────────────────

local UIRemotes = ReplicatedStorage:FindFirstChild("UIRemotes")
if not UIRemotes then
    UIRemotes = Instance.new("Folder")
    UIRemotes.Name = "UIRemotes"
    UIRemotes.Parent = ReplicatedStorage
end
local function ensure(name: string): RemoteEvent
    local r = UIRemotes:FindFirstChild(name)
    if not r then
        r = Instance.new("RemoteEvent"); r.Name = name; r.Parent = UIRemotes
    end
    return r :: RemoteEvent
end
local UIAction = ensure("UIAction")
local UIState  = ensure("UIState")
local UIResult = ensure("UIResult")

-- ── Revision tracking ────────────────────────────────────────────────────

local revisions: { [number]: number } = {}

local function pushState(player: Player)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return end
    local rev = (revisions[player.UserId] or 0) + 1
    revisions[player.UserId] = rev
    local gate = TradingGate.status(profile)
    local snapshot = UIProjection.project(profile, rev, gate)
    UIState:FireClient(player, snapshot)
end

local function reply(player, requestId: string, ok: boolean, messageKey: string?, args: any?)
    UIResult:FireClient(player, {
        requestId = requestId,
        ok = ok,
        message = messageKey and { key = messageKey, args = args or {} } or nil,
    })
end

-- ── Handlers ─────────────────────────────────────────────────────────────
-- Every action the client can fire must appear here. Unknown → err.unknownAction.

local handlers: { [string]: (any, any, any) -> (boolean, string?, any?) } = {}

handlers["build.place"] = function(profile, draft, payload)
    local key = payload.catalogueId
    local x, z, yaw = payload.x, payload.z, payload.yaw
    if type(key) ~= "string"
       or type(x) ~= "number" or type(z) ~= "number" or type(yaw) ~= "number" then
        return false, "err.badArgs"
    end
    return PlotService.applyPlacement(profile, key, { x = x, y = 0, z = z }, yaw)
end

handlers["build.move"] = function(profile, draft, payload)
    local pid = payload.placementId
    local x, z, yaw = payload.x, payload.z, payload.yaw
    if type(pid) ~= "string"
       or type(x) ~= "number" or type(z) ~= "number" or type(yaw) ~= "number" then
        return false, "err.badArgs"
    end
    return PlotService.applyMove(profile, pid, { x = x, y = 0, z = z }, yaw)
end

handlers["build.store"] = function(profile, draft, payload)
    local pid = payload.placementId
    if type(pid) ~= "string" then return false, "err.badArgs" end
    return PlotService.applyStore(profile, pid)
end

handlers["build.recolour"] = function(profile, draft, payload)
    local pid, slot, colour = payload.placementId, payload.colourSlot, payload.colourId
    if type(pid) ~= "string" or type(slot) ~= "string" or type(colour) ~= "string" then
        return false, "err.badArgs"
    end
    return PlotService.applyRecolour(profile, pid, slot, colour)
end

handlers["production.quote"] = function(profile, draft, _payload)
    return ProductionService.quote(profile, draft)
end

handlers["production.start"] = function(profile, draft, payload)
    local quoteId = payload.quoteId
    if type(quoteId) ~= "string" then return false, "err.badArgs" end
    return ProductionService.startFromQuote(profile, quoteId)
end

handlers["production.collect"] = function(profile, draft, payload)
    local jobId = payload.jobId
    if type(jobId) ~= "string" then return false, "err.badArgs" end
    return ProductionService.collect(profile, jobId)
end

handlers["market.visit"] = function(profile, _draft, _payload)
    local ok, reason = TradingGate.canVisitMarket(profile)
    if not ok then return false, reason end
    return true, "market.ready"   -- client performs TeleportService call
end

handlers["settings.save"] = function(profile, draft, _payload)
    if type(draft) ~= "table" then return false, "err.badArgs" end
    local re = draft.reducedEffects
    if type(re) == "boolean" then profile.settings.reducedEffects = re end
    return true
end

handlers["chart.refresh"] = function(_profile, _draft, _payload)
    -- V2A. Acknowledge so client clears the pending indicator.
    return true
end

-- Deferred milestones: acknowledge with a locked reason.
local function lockedHandler(reason: string)
    return function() return false, reason end
end
handlers["partnership.request"]     = lockedHandler("gate.v3")
handlers["partnership.accept"]      = lockedHandler("gate.v3")
handlers["partnership.decline"]     = lockedHandler("gate.v3")
handlers["partnership.vote"]        = lockedHandler("gate.v3")
handlers["partnership.dissolveQuote"] = lockedHandler("gate.v3")
handlers["partnership.dissolve"]    = lockedHandler("gate.v3")
handlers["market.query"]            = lockedHandler("gate.v2b")
handlers["market.list"]             = lockedHandler("gate.v2b")
handlers["market.cancel"]           = lockedHandler("gate.v2b")
handlers["market.offer"]            = lockedHandler("gate.v2b")
handlers["market.accept"]           = lockedHandler("gate.v2b")
handlers["market.confirm"]          = lockedHandler("gate.v2b")
handlers["report"]                  = lockedHandler("gate.m10")
handlers["block"]                   = lockedHandler("gate.m10")
handlers["unblock"]                 = lockedHandler("gate.m10")
handlers["crew.hire"]               = lockedHandler("gate.m2b")
handlers["crew.level"]              = lockedHandler("gate.m2b")
handlers["crew.assign"]             = lockedHandler("gate.m2b")
handlers["crew.unassign"]           = lockedHandler("gate.m2b")
handlers["collection.query"]        = function() return true end    -- read-only
handlers["collection.select"]       = function() return true end
handlers["collection.favourite"]    = lockedHandler("gate.v2a")
handlers["collection.salvageQuote"] = lockedHandler("gate.v2a")
handlers["collection.salvage"]      = lockedHandler("gate.v2a")
handlers["build.theme"]             = lockedHandler("gate.m2b")

-- ── Rate limiting ────────────────────────────────────────────────────────

local buckets: { [number]: { [string]: { tokens: number, lastRefill: number } } } = {}

local function allow(player: Player, action: string): boolean
    local cfg = RateLimits.PerPlayer[action]
    if not cfg then return true end
    local uid = player.UserId
    buckets[uid] = buckets[uid] or {}
    local b = buckets[uid][action]
    local now = os.clock()
    if not b then b = { tokens = cfg.capacity, lastRefill = now }; buckets[uid][action] = b end
    b.tokens = math.min(cfg.capacity, b.tokens + (now - b.lastRefill) * cfg.refillPerSecond)
    b.lastRefill = now
    if b.tokens < 1 then return false end
    b.tokens -= 1
    return true
end

-- ── Intent intake ────────────────────────────────────────────────────────

UIAction.OnServerEvent:Connect(function(player, intent)
    if type(intent) ~= "table" then return end
    local requestId = intent.requestId
    local action    = intent.action
    local revision  = intent.revision
    local draft     = intent.draft
    local payload   = intent.payload
    if type(requestId) ~= "string" or #requestId > 64 then return end
    if type(action) ~= "string" or #action > 64 then return end
    if type(revision) ~= "number" or revision ~= revision then return end
    if type(draft) ~= "table" or type(payload) ~= "table" then return end

    local profile = PlayerDataService.getProfile(player)
    if not profile then
        reply(player, requestId, false, "err.notLoaded")
        return
    end

    -- Idempotency: same requestId seen before on this session is a duplicate.
    profile._session.processedRequests = profile._session.processedRequests or {}
    if profile._session.processedRequests[requestId] then
        reply(player, requestId, false, "err.duplicateRequest")
        return
    end
    profile._session.processedRequests[requestId] = os.time()

    -- Prune old request IDs (keep last 200 or within 5 minutes).
    local cutoff = os.time() - 300
    local count = 0
    for id, ts in pairs(profile._session.processedRequests) do
        count += 1
        if ts < cutoff then profile._session.processedRequests[id] = nil end
    end

    if not allow(player, action) then
        reply(player, requestId, false, "err.rateLimit")
        return
    end

    local handler = handlers[action]
    if not handler then
        reply(player, requestId, false, "err.unknownAction")
        return
    end

    local ok, messageKey, args = handler(profile, draft, payload)
    reply(player, requestId, ok, messageKey, args)
    if ok then
        PlayerDataService.markDirty(player)
        pushState(player)
    end
end)

-- ── Join / leave ─────────────────────────────────────────────────────────

local function onPlayerAdded(player: Player)
    local ok = PlayerDataService.loadForPlayer(player)
    if not ok then
        reply(player, "session", false, "err.loadFailed")
        return
    end
    local profile = PlayerDataService.getProfile(player)
    if profile then
        ProductionService.reconcileOnJoin(profile)
        PlayerDataService.markDirty(player)
    end
    pushState(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayerAdded, p) end
Players.PlayerRemoving:Connect(function(p)
    buckets[p.UserId] = nil
    revisions[p.UserId] = nil
end)

PlayerDataService.init()
print("[Signal Tycoon] M2 bootstrap ready.")