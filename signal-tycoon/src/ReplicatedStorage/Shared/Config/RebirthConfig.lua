--!strict
-- Rebirth thresholds and unlocks per v2.0 section 5.

local RebirthConfig = {}

RebirthConfig.Thresholds = {
    { level = 1, followers = 10_000,  qualityBonus = 2,  unlock = "VerifiedBadge" },
    { level = 2, followers = 25_000,  qualityBonus = 4,  unlock = "CosmeticSet2"  },
    { level = 3, followers = 50_000,  qualityBonus = 6,  unlock = "CosmeticSet3"  },
    { level = 4, followers = 100_000, qualityBonus = 8,  unlock = "CosmeticSet4"  },
    { level = 5, followers = 200_000, qualityBonus = 10, unlock = "LegendTitle"   },
}

RebirthConfig.PostCapStepFollowers = 100_000
RebirthConfig.MaxQualityBonus      = 15

function RebirthConfig.qualityBonusFor(level: number): number
    if level <= 0 then return 0 end
    if level <= #RebirthConfig.Thresholds then
        return RebirthConfig.Thresholds[level].qualityBonus
    end
    local extra = level - #RebirthConfig.Thresholds
    return math.min(
        RebirthConfig.Thresholds[#RebirthConfig.Thresholds].qualityBonus + extra,
        RebirthConfig.MaxQualityBonus
    )
end

function RebirthConfig.followersRequiredFor(level: number): number
    if level <= 0 then return 0 end
    if level <= #RebirthConfig.Thresholds then
        return RebirthConfig.Thresholds[level].followers
    end
    local last = RebirthConfig.Thresholds[#RebirthConfig.Thresholds].followers
    local extra = level - #RebirthConfig.Thresholds
    return last + extra * RebirthConfig.PostCapStepFollowers
end

return RebirthConfig
