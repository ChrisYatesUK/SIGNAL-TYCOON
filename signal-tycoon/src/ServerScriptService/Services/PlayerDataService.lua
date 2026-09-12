--!strict
-- Session-locked player profile store.

local DataStoreService = game:GetService("DataStoreService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared            = ReplicatedStorage:WaitForChild("Shared")
local IdUtil            = require(Shared:WaitForChild("Util"):WaitForChild("IdUtil"))

local PlayerDataService = {}

local CURRENT_SCHEMA = 1
local PROFILE_STORE  = DataStoreService:GetDataStore("SignalTycoon_Profiles_v1")
local LEASE_STORE    = DataStoreService:GetDataStore("SignalTycoon_Leases_v1")

local LEASE_DURATION   = 60 * 5
local LEASE_RENEW      = 60
local AUTOSAVE_PERIOD  = 120
local MAX_LOAD_RETRIES = 4
local RETRY_BASE_DELAY = 2

type Session = {
    profile: any,
    leaseId: string,
    heartbeat: thread,
    autosave: thread,
    dirty: boolean,
}

local sessions: { [number]: Session } = {}
local profileCache: { [number]: any } = {}

local function deepCopy<T>(value: T): T
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value :: any) do
        copy[deepCopy(k)] = deepCopy(v)
    end
    return copy :: T
end

local function defaultProfile(player: Player): any
    return {
        schemaVersion = CURRENT_SCHEMA,
        userId = player.UserId,
        displayName = player.Name,
        credits = 0,
        followers = 0,
        rebirthLevel = 0,
        rebirthHistory = {},
        unlocks = { ["StarterEditor"] = true },
        crew = {
            [IdUtil.prefixed("crew")] = {
                id = IdUtil.prefixed("crew"),
                role = "Editor",
                level = 1,
                xp = 0,
                assignedJobId = nil,
            },
        },
        placements = {},
        jobs = {},
        activeJobId = nil,
        tutorialState = "New",
        collectionIndex = {},
        processedOperationIds = {},
        partnership = nil,
        settings = {
            blockList = {},
            tradeSafetyCompleted = false,
            reducedEffects = false,
            locale = "en",
        },
        moderation = {
            reportCount = 0,
            lastReportAt = nil,
            flags = {},
        },
        _session = {
            leaseId = nil,
            lastSavedAt = 0,
            loadedAt = os.time(),
        },
    }
end

local function migrate(profile: any): any
    if profile.schemaVersion == CURRENT_SCHEMA then return profile end
    profile.schemaVersion = CURRENT_SCHEMA
    return profile
end

local function tryAcquireLease(userId: number, leaseId: string): (boolean, string?)
    local key = "user_" .. userId
    local ok = pcall(function()
        LEASE_STORE:UpdateAsync(key, function(existing)
            local now = os.time()
            if existing and existing.expiresAt and existing.expiresAt > now then
                return nil
            end
            return { leaseId = leaseId, expiresAt = now + LEASE_DURATION }
        end)
    end)
    if not ok then return false, "Lease store error" end
    local finalOk, final = pcall(function() return LEASE_STORE:GetAsync(key) end)
    if not finalOk or not final or final.leaseId ~= leaseId then
        return false, "Lease held by another session"
    end
    return true, nil
end

local function renewLease(userId: number, leaseId: string): boolean
    local key = "user_" .. userId
    local ok = pcall(function()
        LEASE_STORE:UpdateAsync(key, function(existing)
            if not existing or existing.leaseId ~= leaseId then
                return nil
            end
            existing.expiresAt = os.time() + LEASE_DURATION
            return existing
        end)
    end)
    return ok and true or false
end

local function releaseLease(userId: number, leaseId: string)
    local key = "user_" .. userId
    pcall(function()
        LEASE_STORE:UpdateAsync(key, function(existing)
            if existing and existing.leaseId == leaseId then
                return { leaseId = "", expiresAt = 0 }
            end
            return nil
        end)
    end)
end

local function loadProfile(userId: number): (any?, string?)
    local lastErr: string? = nil
    for attempt = 1, MAX_LOAD_RETRIES do
        local ok, result = pcall(function()
            return PROFILE_STORE:GetAsync("user_" .. userId)
        end)
        if ok then
            if result == nil then return nil, "new" end
            return migrate(deepCopy(result)), nil
        end
        lastErr = tostring(result)
        task.wait(RETRY_BASE_DELAY * attempt)
    end
    return nil, lastErr or "Load failed"
end

local function saveProfile(profile: any, leaseId: string): boolean
    local ok = pcall(function()
        PROFILE_STORE:UpdateAsync("user_" .. profile.userId, function(existing)
            if existing and existing._session and existing._session.leaseId
               and existing._session.leaseId ~= leaseId then
                return nil
            end
            local toWrite = deepCopy(profile)
            toWrite._session.leaseId = leaseId
            toWrite._session.lastSavedAt = os.time()
            return toWrite
        end)
    end)
    return ok
end

function PlayerDataService.getProfile(player: Player): any?
    local session = sessions[player.UserId]
    return session and session.profile or nil
end

function PlayerDataService.getProfileByUserId(userId: number): any?
    local session = sessions[userId]
    if session then return session.profile end
    return profileCache[userId]
end

function PlayerDataService.markDirty(player: Player)
    local session = sessions[player.UserId]
    if session then session.dirty = true end
end

function PlayerDataService.saveNow(player: Player): boolean
    local session = sessions[player.UserId]
    if not session then return false end
    if not renewLease(player.UserId, session.leaseId) then return false end
    return saveProfile(session.profile, session.leaseId)
end

function PlayerDataService.loadForPlayer(player: Player): (boolean, string?)
    if sessions[player.UserId] then return true, nil end

    local leaseId = IdUtil.uuid()
    local acquired, leaseErr = tryAcquireLease(player.UserId, leaseId)
    if not acquired then return false, leaseErr or "Session lock failed" end

    local profile, loadErr = loadProfile(player.UserId)
    if profile == nil and loadErr ~= "new" then
        releaseLease(player.UserId, leaseId)
        return false, loadErr or "Profile load failed"
    end
    if profile == nil then profile = defaultProfile(player) end
    profile.userId = player.UserId
    profile.displayName = player.Name
    profile._session.leaseId = leaseId
    profile._session.loadedAt = os.time()

    sessions[player.UserId] = {
        profile = profile,
        leaseId = leaseId,
        heartbeat = task.spawn(function()
            while sessions[player.UserId] do
                task.wait(LEASE_RENEW)
                if not renewLease(player.UserId, leaseId) then break end
            end
        end),
        autosave = task.spawn(function()
            while sessions[player.UserId] do
                task.wait(AUTOSAVE_PERIOD)
                local s = sessions[player.UserId]
                if s and s.dirty then
                    if saveProfile(s.profile, s.leaseId) then s.dirty = false end
                end
            end
        end),
        dirty = false,
    }

    profileCache[player.UserId] = profile
    return true, nil
end

function PlayerDataService.unloadForPlayer(player: Player)
    local session = sessions[player.UserId]
    if not session then return end

    if renewLease(player.UserId, session.leaseId) then
        saveProfile(session.profile, session.leaseId)
    end

    if session.heartbeat then task.cancel(session.heartbeat) end
    if session.autosave then task.cancel(session.autosave) end

    releaseLease(player.UserId, session.leaseId)
    sessions[player.UserId] = nil
    task.delay(300, function()
        if not sessions[player.UserId] then
            profileCache[player.UserId] = nil
        end
    end)
end

function PlayerDataService.init()
    Players.PlayerRemoving:Connect(function(player)
        PlayerDataService.unloadForPlayer(player)
    end)

    game:BindToClose(function()
        if RunService:IsStudio() then return end
        for _, player in ipairs(Players:GetPlayers()) do
            PlayerDataService.saveNow(player)
        end
        task.wait(2)
    end)
end

return PlayerDataService
