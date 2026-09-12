--!strict
-- Quality bonuses, follower grants, crew XP.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ProductionConfig = require(Shared:WaitForChild("Config"):WaitForChild("ProductionConfig"))
local RebirthConfig = require(Shared:WaitForChild("Config"):WaitForChild("RebirthConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local ProgressionService = {}

function ProgressionService.rebirthQualityBonus(profile)
    return RebirthConfig.qualityBonusFor(profile.rebirthLevel)
end

function ProgressionService.computeFollowerGain(profile, job, streak)
    local base = ProductionConfig.FollowerBase
    local qualityBonus = math.floor(job.quality / 10)
    local streakBonus = math.min(streak, ProductionConfig.FollowerStreakMax)
                        * ProductionConfig.FollowerStreakPer
    return base + qualityBonus + streakBonus
end

local function readStreak(profile, categoryId)
    local key = "streak:" .. categoryId
    local v = profile.unlocks[key]
    if typeof(v) ~= "number" then return 0 end
    return v
end

local function writeStreak(profile, categoryId, streak)
    profile.unlocks["streak:" .. categoryId] = streak
end

function ProgressionService.grantJobRewards(player, job)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return end

    local streak = readStreak(profile, job.category)
    local followerGain = ProgressionService.computeFollowerGain(profile, job, streak)
    local creditGain = 25 + math.floor(job.quality / 4)

    profile.credits += creditGain
    profile.followers += followerGain

    writeStreak(profile, job.category, streak + 1)

    for _, crewId in ipairs(job.snapshot.assignedCrewIds) do
        local member = profile.crew[crewId]
        if member then
            member.xp += ProductionConfig.CrewXpPerJob
            local threshold = 100 * member.level
            while member.xp >= threshold and member.level < 5 do
                member.xp -= threshold
                member.level += 1
                threshold = 100 * member.level
            end
        end
    end
end

return ProgressionService
