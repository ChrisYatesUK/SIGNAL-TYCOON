--!strict
-- Fire-and-forget analytics. No-op when the VPS client is disabled.

local VpsClient = require(script.Parent.Parent:WaitForChild("Backend"):WaitForChild("VpsClient"))

local AnalyticsService = {}

local queue: { { event: string, payload: any, ts: number } } = {}
local MAX_QUEUE = 500

function AnalyticsService.track(event: string, payload: any?)
    if #queue >= MAX_QUEUE then
        table.remove(queue, 1)
    end
    table.insert(queue, {
        event = event,
        payload = payload or {},
        ts = os.time(),
    })
    -- Non-blocking flush attempt.
    task.spawn(function()
        if VpsClient.isEnabled() then
            VpsClient.postAnalyticsBatch(queue)
        end
    end)
end

return AnalyticsService
