--!strict
-- Production state machine: Idle → Rendering → Ready → Collected.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local IdUtil = require(Shared:WaitForChild("Util"):WaitForChild("IdUtil"))
local ProductionConfig = require(Shared:WaitForChild("Config"):WaitForChild("ProductionConfig"))
local RarityConfig = require(Shared:WaitForChild("Config"):WaitForChild("RarityConfig"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))

local ProductionService = {}

local function pushJobUpdate(player: Player, job)
    local remotes = ReplicatedStorage:FindFirstChild("SignalTycoonRemotes")
    if not remotes then return end
    local ev = remotes:FindFirstChild("JobStateChanged") :: RemoteEvent?
    if ev then ev:FireClient(player, job) end
end

local function scheduleCompletion(player: Player, job)
    task.spawn(function()
        local remaining = job.completesAt - os.time()
        if remaining > 0 then task.wait(remaining) end
        local profile = PlayerDataService.getProfile(player)
        if not profile then return end
        local current = profile.jobs[job.jobId]
        if not current then return end
        if current.state ~= "Rendering" then return end
        current.state = "Ready"
        PlayerDataService.markDirty(player)
        pushJobUpdate(player, current)
    end)
end

function ProductionService.requestStart(player, categoryId, assignedCrewIds, snapshotPlacementIds)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return false, "Profile not loaded", nil end

    if profile.activeJobId then
        local existing = profile.jobs[profile.activeJobId]
        if existing and (existing.state == "Rendering" or existing.state == "Ready") then
            return false, "A production is already in progress", nil
        end
    end

    local categoryValid = false
    for _, id in ipairs({ "Gaming", "Comedy", "Music" }) do
        if id == categoryId then categoryValid = true break end
    end
    if not categoryValid then return false, "Unknown category", nil end

    local crewScore = 0
    local assignedSet = {}
    for _, crewId in ipairs(assignedCrewIds) do
        if assignedSet[crewId] then return false, "Duplicate crew assignment", nil end
        assignedSet[crewId] = true
        local member = profile.crew[crewId]
        if not member then return false, "Unknown crew member", nil end
        if member.assignedJobId then return false, "Crew already assigned", nil end
        crewScore += math.min(10, member.level * 5)
    end
    crewScore = math.min(crewScore, ProductionConfig.Quality.CrewMax)

    local equipmentScore = 0
    for _, pid in ipairs(snapshotPlacementIds) do
        local p = profile.placements[pid]
        if not p then return false, "Equipment placement missing", nil end
        equipmentScore += 10
    end
    equipmentScore = math.min(equipmentScore, ProductionConfig.Quality.EquipmentMax)

    local themeScore = 0
    local rebirthBonus = ProgressionService.rebirthQualityBonus(profile)

    local quality = math.clamp(
        equipmentScore + crewScore + themeScore + rebirthBonus,
        0, 100
    )

    local duration = ProductionConfig.StarterProductionDuration
    local now = os.time()
    local jobId = IdUtil.prefixed("job")
    local job = {
        jobId = jobId,
        category = categoryId,
        quality = quality,
        state = "Rendering",
        startedAt = now,
        completesAt = now + duration,
        collectedAt = nil,
        snapshot = {
            equipmentScore = equipmentScore,
            crewScore = crewScore,
            themeScore = themeScore,
            categoryId = categoryId,
            assignedCrewIds = assignedCrewIds,
        },
        provisionalRarity = RarityConfig.forQuality(quality),
        finalRarity = nil,
        settlementVersion = nil,
    }

    profile.jobs[jobId] = job
    profile.activeJobId = jobId
    for _, crewId in ipairs(assignedCrewIds) do
        profile.crew[crewId].assignedJobId = jobId
    end

    PlayerDataService.markDirty(player)
    scheduleCompletion(player, job)
    pushJobUpdate(player, job)
    return true, nil, job
end

function ProductionService.requestCollect(player, jobId)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return false, "Profile not loaded" end

    local job = profile.jobs[jobId]
    if not job then return false, "Job not found" end

    if job.state == "Collected" then return true, nil end
    if job.state ~= "Ready" then return false, "Job not ready" end

    job.state = "Collected"
    job.collectedAt = os.time()

    ProgressionService.grantJobRewards(player, job)

    for _, crewId in ipairs(job.snapshot.assignedCrewIds) do
        local member = profile.crew[crewId]
        if member then member.assignedJobId = nil end
    end

    if profile.activeJobId == jobId then
        profile.activeJobId = nil
    end

    PlayerDataService.markDirty(player)
    pushJobUpdate(player, job)
    return true, nil
end

function ProductionService.reconcileOnJoin(player: Player)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return end
    local jobId = profile.activeJobId
    if not jobId then return end
    local job = profile.jobs[jobId]
    if not job then return end
    if job.state == "Rendering" and os.time() >= job.completesAt then
        job.state = "Ready"
        PlayerDataService.markDirty(player)
        pushJobUpdate(player, job)
    end
end

return ProductionService
