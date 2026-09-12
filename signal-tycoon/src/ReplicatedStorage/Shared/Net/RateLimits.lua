--!strict
-- Per-remote token bucket sizes. Server-side enforcement only.

local RateLimits = {}

RateLimits.PerPlayer = {
    RequestPlacement   = { capacity = 6,  refillPerSecond = 1.0 },
    RequestMove        = { capacity = 10, refillPerSecond = 2.0 },
    RequestStore       = { capacity = 10, refillPerSecond = 2.0 },
    RequestRecolour    = { capacity = 10, refillPerSecond = 2.0 },

    RequestStartJob    = { capacity = 3,  refillPerSecond = 0.2 },
    RequestCollectJob  = { capacity = 5,  refillPerSecond = 1.0 },

    RequestHireCrew    = { capacity = 3,  refillPerSecond = 0.2 },
    RequestRebirth     = { capacity = 1,  refillPerSecond = 0.05 },

    SubmitReport       = { capacity = 5,  refillPerSecond = 0.0006 },
    BlockPlayer        = { capacity = 10, refillPerSecond = 0.05 },
    UnblockPlayer      = { capacity = 10, refillPerSecond = 0.05 },
}

return RateLimits
