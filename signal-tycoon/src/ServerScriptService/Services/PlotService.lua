--!strict
-- Server-authoritative plot placement.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local IdUtil = require(Shared:WaitForChild("Util"):WaitForChild("IdUtil"))
local CatalogConfig = require(Shared:WaitForChild("Config"):WaitForChild("CatalogConfig"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local PlotService = {}

local GRID_SIZE = 2
local PLOT_MAX_OFFSET = 30

local function isMultiple(value: number, step: number): boolean
    return math.abs((value / step) - math.floor(value / step + 0.5)) < 1e-6
end

local function snapToGrid(value: number): number
    return math.floor(value / GRID_SIZE + 0.5) * GRID_SIZE
end

local function withinPlotBounds(position, footprint): boolean
    local halfX = footprint.x / 2
    local halfZ = footprint.z / 2
    return math.abs(position.x) + halfX <= PLOT_MAX_OFFSET
        and math.abs(position.z) + halfZ <= PLOT_MAX_OFFSET
end

local function footprintFor(entry, rotationY)
    if rotationY % 180 == 90 then
        return { x = entry.footprint.z, z = entry.footprint.x }
    end
    return entry.footprint
end

local function overlaps(aPos, aFoot, bPos, bFoot): boolean
    local ax1, ax2 = aPos.x - aFoot.x/2, aPos.x + aFoot.x/2
    local az1, az2 = aPos.z - aFoot.z/2, aPos.z + aFoot.z/2
    local bx1, bx2 = bPos.x - bFoot.x/2, bPos.x + bFoot.x/2
    local bz1, bz2 = bPos.z - bFoot.z/2, bPos.z + bFoot.z/2
    return ax1 < bx2 and ax2 > bx1 and az1 < bz2 and az2 > bz1
end

function PlotService.requestPlacement(player, catalogKey, rawPosition, rawRotationY)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return false, "Profile not loaded" end

    local entry = CatalogConfig.byKey(catalogKey)
    if not entry then return false, "Unknown catalogue item" end

    local allowed = false
    for _, r in ipairs(entry.allowedRotations) do
        if rawRotationY == r then allowed = true break end
    end
    if not allowed then return false, "Invalid rotation" end

    local pos = {
        x = snapToGrid(rawPosition.x),
        y = snapToGrid(rawPosition.y),
        z = snapToGrid(rawPosition.z),
    }
    if not isMultiple(pos.x, GRID_SIZE) or not isMultiple(pos.z, GRID_SIZE) then
        return false, "Placement not on grid"
    end

    local foot = footprintFor(entry, rawRotationY)
    if not withinPlotBounds(pos, foot) then
        return false, "Outside plot bounds"
    end

    for _, existing in pairs(profile.placements) do
        local exEntry = CatalogConfig.byKey(existing.catalogKey)
        if exEntry then
            local exFoot = footprintFor(exEntry, existing.rotationY)
            if overlaps(pos, foot, existing.position, exFoot) then
                return false, "Overlaps an existing object"
            end
        end
    end

    local unlockKey = "catalog:" .. catalogKey
    if not profile.unlocks[unlockKey] and entry.baseCost > 0 then
        return false, "Item not unlocked"
    end
    if profile.credits < entry.baseCost then
        return false, "Insufficient credits"
    end

    profile.credits -= entry.baseCost
    local placementId = IdUtil.prefixed("pl")
    profile.placements[placementId] = {
        placementId = placementId,
        catalogKey = catalogKey,
        position = pos,
        rotationY = rawRotationY,
        colourSlot = nil,
    }
    PlayerDataService.markDirty(player)
    return true, nil
end

function PlotService.requestMove(player, placementId, rawPosition, rawRotationY)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return false, "Profile not loaded" end

    local existing = profile.placements[placementId]
    if not existing then return false, "Placement not found" end

    local entry = CatalogConfig.byKey(existing.catalogKey)
    if not entry then return false, "Unknown catalogue item" end

    local allowed = false
    for _, r in ipairs(entry.allowedRotations) do
        if rawRotationY == r then allowed = true break end
    end
    if not allowed then return false, "Invalid rotation" end

    local pos = {
        x = snapToGrid(rawPosition.x),
        y = snapToGrid(rawPosition.y),
        z = snapToGrid(rawPosition.z),
    }
    local foot = footprintFor(entry, rawRotationY)
    if not withinPlotBounds(pos, foot) then
        return false, "Outside plot bounds"
    end

    for pid, other in pairs(profile.placements) do
        if pid ~= placementId then
            local otherEntry = CatalogConfig.byKey(other.catalogKey)
            if otherEntry then
                local otherFoot = footprintFor(otherEntry, other.rotationY)
                if overlaps(pos, foot, other.position, otherFoot) then
                    return false, "Overlaps an existing object"
                end
            end
        end
    end

    existing.position = pos
    existing.rotationY = rawRotationY
    PlayerDataService.markDirty(player)
    return true, nil
end

function PlotService.requestStore(player, placementId)
    local profile = PlayerDataService.getProfile(player)
    if not profile then return false, "Profile not loaded" end
    if not profile.placements[placementId] then
        return false, "Placement not found"
    end
    profile.placements[placementId] = nil
    PlayerDataService.markDirty(player)
    return true, nil
end

return PlotService
