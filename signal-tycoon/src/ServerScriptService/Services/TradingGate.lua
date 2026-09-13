--!strict
-- Gate for market access. Thresholds from 16-Onboarding.md:
--   tutorial completed + 10 collected productions + 24h since first play.
-- No paid bypass. See v2.0 §1 and §13.

local TradingGate = {}

local MIN_PRODUCTIONS = 10
local MIN_HOURS       = 24
local FINAL_TUTORIAL  = "collectionSeen"

export type GateStatus = {
    locked: boolean,
    reason: string?,
    remaining: { productions: number?, hours: number? }?,
}

function TradingGate.status(profile): GateStatus
    if profile.tutorialState ~= FINAL_TUTORIAL then
        return { locked = true, reason = "gate.tutorial" }
    end

    local completed = 0
    for _, job in pairs(profile.jobs) do
        if job.state == "Collected" then completed += 1 end
    end
    if completed < MIN_PRODUCTIONS then
        return {
            locked = true,
            reason = "gate.productions",
            remaining = { productions = MIN_PRODUCTIONS - completed },
        }
    end

    local firstPlayAt = profile._session and profile._session.firstPlayAt
    if type(firstPlayAt) ~= "number" then
        -- Migration edge case: profile predates the field. Treat as just now.
        return {
            locked = true,
            reason = "gate.hours",
            remaining = { hours = MIN_HOURS },
        }
    end

    local elapsedHours = (os.time() - firstPlayAt) / 3600
    if elapsedHours < MIN_HOURS then
        return {
            locked = true,
            reason = "gate.hours",
            remaining = { hours = math.ceil(MIN_HOURS - elapsedHours) },
        }
    end

    return { locked = false }
end

function TradingGate.canVisitMarket(profile): (boolean, string?)
    local s = TradingGate.status(profile)
    if s.locked then return false, s.reason end
    return true, nil
end

return TradingGate