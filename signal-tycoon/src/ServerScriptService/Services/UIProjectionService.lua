--!strict
-- Transforms PlayerProfile into a UIState snapshot matching UI-Data-Contract.md.
-- All formatting happens here so the client never computes server-authoritative
-- values. Rows use {key, args} for every player-visible string.
--
-- This service is read-only: it never mutates the profile.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CatalogConfig = require(Shared:WaitForChild("Config"):WaitForChild("CatalogConfig"))
local ProductionConfig = require(Shared:WaitForChild("Config"):WaitForChild("ProductionConfig"))

local UIProjectionService = {}

-- ── Number formatting ────────────────────────────────────────────────────

local function formatCompact(n: number): string
    if n < 1000 then return tostring(math.floor(n)) end
    if n < 10000 then return string.format("%.1fK", n / 1000) end
    if n < 1000000 then return string.format("%dK", math.floor(n / 1000)) end
    return string.format("%.1fM", n / 1000000)
end

-- ── Row constructors (helpers) ───────────────────────────────────────────

local function rowLabel(id, textKey, args)
    return { id = id, kind = "label", text = { key = textKey, args = args or {} } }
end

local function rowCard(id, textKey, textArgs, detailKey, detailArgs, rarity)
    return {
        id = id, kind = "card",
        text = { key = textKey, args = textArgs or {} },
        detail = detailKey and { key = detailKey, args = detailArgs or {} } or nil,
        rarity = rarity,
    }
end

local function rowProgress(id, textKey, textArgs, current, maximum)
    return {
        id = id, kind = "progress",
        text = { key = textKey, args = textArgs or {} },
        current = current, maximum = maximum,
    }
end

local function rowTimer(id, textKey, deadline)
    return { id = id, kind = "timer",
             text = { key = textKey }, deadline = deadline }
end

local function rowAction(id, textKey, textArgs, action, payload, opts)
    opts = opts or {}
    return {
        id = id, kind = "action",
        text = { key = textKey, args = textArgs or {} },
        action = action, payload = payload or {},
        enabled = opts.enabled, reason = opts.reason,
        confirm = opts.confirm, notBefore = opts.notBefore,
        bindings = opts.bindings,
    }
end

local function rowChoice(id, field, textKey, value, options)
    return {
        id = id, kind = "choice",
        text = { key = textKey }, field = field,
        value = value, options = options,
    }
end

-- ── HUD ──────────────────────────────────────────────────────────────────

local function projectHUD(profile, gate): any
    local phase = "idle"
    local completesAt = nil
    if profile.activeJobId then
        local job = profile.jobs[profile.activeJobId]
        if job then
            if job.state == "Rendering" then phase = "rendering"
            elseif job.state == "Ready" then phase = "ready"
            elseif job.state == "Collected" then phase = "idle" end
            completesAt = job.completesAt
        end
    end

    return {
        credits = formatCompact(profile.credits),
        followers = formatCompact(profile.followers),
        phase = phase,
        completesAt = completesAt,
        partner = nil,   -- V3; HUD reads "solo" fallback when nil
        marketLocked = gate.locked,
        marketReason = gate.reason,
    }
end

-- ── Build Catalogue ──────────────────────────────────────────────────────

local function projectBuild(profile): any
    local rows = {}
    local unlockedCount = 0

    for _, entry in ipairs(CatalogConfig.all()) do
        local unlocked = profile.unlocks["catalog:" .. entry.key] == true
                or entry.baseCost == 0
        if unlocked then unlockedCount += 1 end

        local enabled = unlocked and profile.credits >= entry.baseCost
        local reason = nil
        if not unlocked then reason = "catalog.locked"
        elseif profile.credits < entry.baseCost then reason = "catalog.tooExpensive" end

        rows[#rows + 1] = {
            id = entry.key,
            kind = "action",
            text = { key = entry.displayNameKey },
            detail = {
                key = "catalog.meta",
                args = {
                    cost = entry.baseCost,
                    footprint = string.format("%dx%d", entry.footprint.x, entry.footprint.z),
                },
            },
            action = "build.select",
            payload = { catalogueId = entry.key },
            enabled = true,   -- selection is always allowed; Place gates on cost
        }
    end

    return { rows = rows, revision = 1 }
end

-- ── Crew Panel ───────────────────────────────────────────────────────────

local function projectCrew(profile): any
    local rows = {}

    for crewId, member in pairs(profile.crew) do
        local maxXp = 100 * member.level
        rows[#rows + 1] = rowProgress(
            "crew_" .. crewId,
            "crew.row",
            { name = crewId, role = member.role, level = member.level },
            member.xp, maxXp
        )
        if member.assignedJobId then
            rows[#rows + 1] = rowLabel("crew_assigned_" .. crewId,
                "crew.assigned", { jobId = member.assignedJobId })
        end
    end

    rows[#rows + 1] = rowAction(
        "crew_hire", "crew.hire", {}, "crew.hire", {}, { enabled = false,
        reason = { key = "err.notImplemented" } })

    return { rows = rows, revision = 1 }
end

-- ── Production Panel ─────────────────────────────────────────────────────

local function projectProduction(profile): any
    local rows = {}

    -- Category choices (static for MVP)
    local categoryOptions = {
        { id = "Gaming", text = { key = "category.gaming" } },
        { id = "Comedy", text = { key = "category.comedy" } },
        { id = "Music",  text = { key = "category.music" } },
    }
    rows[#rows + 1] = rowChoice(
        "production_category", "categoryId",
        "production.chooseCategory", nil, categoryOptions)

    -- Crew choices (list current crew)
    local crewOptions = {}
    for crewId, member in pairs(profile.crew) do
        crewOptions[#crewOptions + 1] = {
            id = crewId,
            text = { key = "crew.option", args = { id = crewId, role = member.role } },
        }
    end
    rows[#rows + 1] = {
        id = "production_crew", kind = "multiChoice",
        text = { key = "production.chooseCrew" },
        field = "crewIds", value = {}, options = crewOptions,
    }

    -- Active job display
    if profile.activeJobId then
        local job = profile.jobs[profile.activeJobId]
        if job then
            if job.state == "Rendering" then
                rows[#rows + 1] = rowTimer("production_timer",
                    "production.rendering", job.completesAt)
            elseif job.state == "Ready" then
                rows[#rows + 1] = rowAction(
                    "production_collect", "production.collect", {},
                    "production.collect",
                    { jobId = job.jobId })
            end
        end
    else
        rows[#rows + 1] = rowAction(
            "production_quote", "production.requestQuote", {},
            "production.quote", {})
    end

    return { rows = rows, revision = 1 }
end

-- ── Collection Panel ─────────────────────────────────────────────────────

local function projectCollection(profile): any
    local rows = {}
    -- MVP: Studio Series souvenirs only, non-tradable.
    -- V2A will populate weekly Drops here.
    for dropId, status in pairs(profile.collectionIndex) do
        if status == "active" then
            rows[#rows + 1] = rowCard(
                "drop_" .. dropId,
                "collection.studioSeries",
                { id = dropId },
                "collection.detail",
                { status = "permanent" },
                nil)
        end
    end
    if #rows == 0 then
        rows[#rows + 1] = rowLabel("collection_empty", "collection.empty", {})
    end
    return { rows = rows, revision = 1 }
end

-- ── Settings ─────────────────────────────────────────────────────────────

local function projectSettings(profile): any
    local rows = {}
    rows[#rows + 1] = rowAction(
        "settings_reduced",
        if profile.settings.reducedEffects
            then "settings.reducedOn" else "settings.reducedOff",
        {}, "settings.toggle", {})
    rows[#rows + 1] = rowAction(
        "settings_quieter", "settings.quieter", {}, "settings.quieter", {})
    rows[#rows + 1] = rowAction(
        "settings_louder", "settings.louder", {}, "settings.louder", {})
    return { rows = rows, revision = 1 }
end

-- ── Chart / Market / Partnership / Report: placeholders until their milestones
-- Return empty rows so the screens render a "loading" state, not an error.

local function emptyScreen(): any
    return { rows = {}, revision = 1 }
end

-- ── Public entry point ───────────────────────────────────────────────────

function UIProjectionService.project(profile, revision, gate): any
    return {
        revision = revision,
        hud = projectHUD(profile, gate),
        screens = {
            HUD             = emptyScreen(),
            BuildCatalogue  = projectBuild(profile),
            CrewPanel       = projectCrew(profile),
            ProductionPanel = projectProduction(profile),
            CollectionPanel = projectCollection(profile),
            Settings        = projectSettings(profile),
            -- Deferred to later milestones:
            ChartBoard       = emptyScreen(),
            PartnershipPanel = emptyScreen(),
            MarketplaceHub   = emptyScreen(),
            ReportDialog     = emptyScreen(),
        },
        settings = {
            reducedEffects = profile.settings.reducedEffects,
            volume = 1,
            locale = profile.settings.locale,
        },
    }
end

return UIProjectionService