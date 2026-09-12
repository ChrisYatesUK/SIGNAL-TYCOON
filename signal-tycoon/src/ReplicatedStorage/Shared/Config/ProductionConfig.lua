--!strict
-- Production tuning. Values are planning assumptions per v2.0 section M1.

local ProductionConfig = {}

ProductionConfig.TutorialProductionDuration = 60
ProductionConfig.StarterProductionDuration  = 120

ProductionConfig.Quality = {
    EquipmentMax = 50,
    CrewMax      = 30,
    ThemeMax     = 20,
}

ProductionConfig.TutorialForcedQuality = 35
ProductionConfig.MaxConcurrentJobs     = 1

ProductionConfig.FollowerBase      = 10
ProductionConfig.FollowerStreakMax = 5
ProductionConfig.FollowerStreakPer = 2
ProductionConfig.CrewXpPerJob      = 25

ProductionConfig.BaseDurationByTier = {
    [1] = 120,
    [2] = 100,
    [3] = 85,
}

return ProductionConfig
