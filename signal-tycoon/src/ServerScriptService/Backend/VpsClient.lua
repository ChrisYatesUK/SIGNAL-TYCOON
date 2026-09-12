--!strict
-- VPS API client. Disabled by default; enable once the VPS endpoint exists.
--
-- When enabled, this client only sends fire-and-forget data. It is NOT the
-- authoritative store for any player state. See build plan section 6.

local HttpService = game:GetService("HttpService")

local VpsClient = {}

local ENABLED = false                -- flip to true when the endpoint is live
local BASE_URL = "https://api.signaltycoon.example"  -- replace with real domain
local API_KEY = ""                   -- load from ServerStorage/Secrets when enabled

function VpsClient.isEnabled(): boolean
    return ENABLED and BASE_URL ~= "" and API_KEY ~= ""
end

function VpsClient.postAnalyticsBatch(batch)
    if not VpsClient.isEnabled() then return end
    pcall(function()
        HttpService:PostAsync(
            BASE_URL .. "/v1/analytics/batch",
            HttpService:JSONEncode({ events = batch }),
            Enum.HttpContentType.ApplicationJson,
            false,
            { ["X-Api-Key"] = API_KEY }
        )
    end)
end

return VpsClient
