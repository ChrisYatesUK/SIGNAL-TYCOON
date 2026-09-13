--!strict
-- Production state machine with quote → start → collect.
-- Quality is fixed at start time. Quote is server-computed and expires.
-- Rewards are granted exactly once; re-issue of collect is a no-op.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local IdUtil = require(Shared:WaitForChild("Util"):WaitForChild("IdUtil"))
local ProductionConfig = require(Shared:WaitForChild("Config"):WaitForChild("ProductionConfig"))
local RarityConfig = require(Shared:WaitForChild("Config"):WaitForChild("RarityConfig"))
local CatalogConfig = require(Shared:WaitForChild("Config"):WaitForChild("CatalogConfig"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))

local ProductionService = {}

local QUOTE_TTL = 90   -- seconds

-- ── Internal helpers ─────────────────────────────────────────────────────

local function computeQuality(profile, categoryId, crewIds, placementIds)
    local equipmentScore = 0
    for _, pid in ipairs(placementIds) do
        local p = profile.placements[pid]
        if p then
            local entry = CatalogConfig.byKey(p.catalogKey)
            if entry then equipmentScore += entry.equipmentScore end
        end
    end
    equipmentScore = math.min(equipmentScore, ProductionConfig.Quality.EquipmentMax)

    local crewScore = 0
    for _, cid in ipairs(crewIds) do
        local m = profile.crew[cid]
        if m then crewScore += math.min(10, m.level * 5) end
    end
    crewScore = math.min(crewScore, ProductionConfig.Quality.CrewMax)

    local themeScore = 0
    local rebirthBonus = ProgressionService.rebirthQualityBonus(profile)

    return math.clamp(equipmentScore + crewScore + themeScore + rebirthBonus, 0, 100),
           equipmentScore, crewScore, themeScore
end

local function validateCategory(categoryId: string): boolean
    for _, id in ipairs({ "Gaming", "Comedy", "Music" }) do
        if id == categoryId then return true end
    end
    return false
end

local function validateCrew(profile, crewIds): (boolean, string?)
    local seen: { [string]: boolean } = {}
    for _, cid in ipairs(crewIds) do
        if seen[cid] then return false, "err.dupCrew" end
        seen[cid] = true
        local m = profile.crew[cid]
        if not m then return false, "err.unknownCrew" end
        if m.assignedJobId then return false, "err.crewBusy" end
    end
    return true, nil
end

local function validateEquipment(profile, placementIds): (boolean, string?)
    for _, pid in ipairs(placementIds) do
        if not profile.placements[pid] then return false, "err.missingPlacement" end
    end
    return true, nil
end

-- ── Public API ───────────────────────────────────────────────────────────

function ProductionService.quote(profile, draft): (boolean, string?, any?)
    local categoryId = draft.categoryId
    local crewIds = draft.crewIds or {}
    local placementIds = draft.placementIds or {}

    if type(categoryId) ~= "string" or not validateCategory(categoryId) then
        return false, "err.badCategory"
    end
    local okCrew, errCrew = validateCrew(profile, crewIds)
    if not okCrew then return false, errCrew end
    local okEq, errEq = validateEquipment(profile, placementIds)
    if not okEq then return false, errEq end

    local quality, eq, cr, th = computeQuality(profile, categoryId, crewIds, placementIds)
    local quoteId = IdUtil.prefixed("quote")

    profile._session = profile._session or {}
    profile._session.quotes = profile._session.quotes or {}
    profile._session.quotes[quoteId] = {
        quoteId = quoteId,
        categoryId = categoryId,
        crewIds = crewIds,
        placementIds = placementIds,
        quality = quality,
        breakdown = { equipment = eq, crew = cr, theme = th },
        expiresAt = os.time() + QUOTE_TTL,
    }

    -- Prune expired quotes opportunistically.
    local now = os.time()
    for id, q in pairs(profile._session.quotes) do
        if q.expiresAt < now then profile._session.quotes[id] = nil end
    end

    return true, nil, {
        quoteId = quoteId,
        quality = quality,
        breakdown = { equipment = eq, crew = cr, theme = th },
        expiresAt = os.time() + QUOTE_TTL,
        duration = ProductionConfig.StarterProductionDuration,
    }
end

function ProductionService.startFromQuote(profile, quoteId): (boolean, string?, any?)
    local quotes = profile._session and profile._session.quotes
    local quote = quotes and quotes[quoteId]
    if not quote then return false, "err.quoteExpired" end
    if os.time() > quote.expiresAt then
        quotes[quoteId] = nil
        return false, "err.quoteExpired"
    end

    -- Re-validate crew and equipment at start time (state may have changed).
    local okCrew, errCrew = validateCrew(profile, quote.crewIds)
    if not okCrew then return false, errCrew end
    local okEq, errEq = validateEquipment(profile, quote.placementIds)
    if not okEq then return false, errEq end

    if profile.activeJobId then
        local existing = profile.jobs[profile.activeJobId]
        if existing and (existing.state == "Rendering" or existing.state == "Ready") then
            return false, "err.jobInProgress"
        end
    end

    local now = os.time()
    local jobId = IdUtil.prefixed("job")
    local job = {
        jobId = jobId,
        category = quote.categoryId,
        quality = quote.quality,
        state = "Rendering",
        startedAt = now,
        completesAt = now + ProductionConfig.StarterProductionDuration,
        collectedAt = nil,
        snapshot = {
            equipmentScore = quote.breakdown.equipment,
            crewScore = quote.breakdown.crew,
            themeScore = quote.breakdown.theme,
            categoryId = quote.categoryId,
            assignedCrewIds = quote.crewIds,
            placementIds = quote.placementIds,
        },
        provisionalRarity = RarityConfig.forQuality(quote.quality),
        finalRarity = nil,
        settlementVersion = nil,
    }

    profile.jobs[jobId] = job
    profile.activeJobId = jobId
    for _, cid in ipairs(quote.crewIds) do
        profile.crew[cid].assignedJobId = jobId
    end
    quotes[quoteId] = nil

    return true, nil, job
end

function ProductionService.collect(profile, jobId): (boolean, string?, any?)
    local job = profile.jobs[jobId]
    if not job then return false, "err.jobNotFound" end
    if job.state == "Collected" then return true, nil, job end
    if job.state ~= "Ready" then return false, "err.jobNotReady" end

    job.state = "Collected"
    job.collectedAt = os.time()

    ProgressionService.grantJobRewards(profile, job)

    for _, cid in ipairs(job.snapshot.assignedCrewIds) do
        local m = profile.crew[cid]
        if m then m.assignedJobId = nil end
    end
    if profile.activeJobId == jobId then profile.activeJobId = nil end

    return true, nil, job
end

-- Called on rejoin to reconcile jobs that finished offline.
function ProductionService.reconcileOnJoin(profile)
    local jobId = profile.activeJobId
    if not jobId then return end
    local job = profile.jobs[jobId]
    if not job then return end
    if job.state == "Rendering" and os.time() >= job.completesAt then
        job.state = "Ready"
    end
end

return ProductionService