--!strict
-- UUID v4 generator. Use for job IDs, placement IDs, Drop IDs.

local HttpService = game:GetService("HttpService")

local IdUtil = {}

function IdUtil.uuid(): string
    return HttpService:GenerateGUID(false)
end

function IdUtil.prefixed(prefix: string): string
    return prefix .. "_" .. string.sub(HttpService:GenerateGUID(false), 1, 8)
end

return IdUtil
