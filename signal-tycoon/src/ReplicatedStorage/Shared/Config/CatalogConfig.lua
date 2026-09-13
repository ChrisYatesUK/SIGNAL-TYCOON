--!strict
-- Placeable catalogue. One entry per mesh. Footprint is the max across themes
-- (see M2 decisions); theme is compositional, not structural.
--
-- catalogueId sent by the UI maps directly to `key` here and is persisted in
-- profile.placements[*].catalogKey. Never rename a key after shipping.

export type Entry = {
    key: string,
    displayNameKey: string,        -- localisation key, e.g. "catalog.camera_t1"
    category: "equipment" | "decor" | "display",
    footprint: { x: number, z: number },   -- studs, even dimensions
    allowedRotations: { number },
    themeId: string?,              -- nil = fits any theme
    equipmentTier: number?,        -- nil for non-equipment
    equipmentRole: "camera" | "computer" | "lighting"?,
    equipmentScore: number,        -- contributes to production quality
    baseCost: number,              -- Studio Credits
    colourSlots: { string },
    sourceAssetKey: string,        -- Asset-Register.csv AssetKey
}

local CatalogConfig = {}

local ENTRIES: { Entry } = {
    -- ── Equipment: cameras ─────────────────────────────────────────────
    { key = "camera_t1", displayNameKey = "catalog.camera_t1",
      category = "equipment", footprint = { x = 2, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentTier = 1, equipmentRole = "camera", equipmentScore = 10,
      baseCost = 0, colourSlots = {}, sourceAssetKey = "O.Camera1" },

    { key = "camera_t2", displayNameKey = "catalog.camera_t2",
      category = "equipment", footprint = { x = 4, z = 2 },
      allowedRotations = { 0, 180 }, themeId = nil,
      equipmentTier = 2, equipmentRole = "camera", equipmentScore = 16,
      baseCost = 150, colourSlots = {}, sourceAssetKey = "O.Camera2" },

    { key = "camera_t3", displayNameKey = "catalog.camera_t3",
      category = "equipment", footprint = { x = 4, z = 4 },
      allowedRotations = { 0, 180 }, themeId = nil,
      equipmentTier = 3, equipmentRole = "camera", equipmentScore = 22,
      baseCost = 400, colourSlots = {}, sourceAssetKey = "O.Camera3" },

    -- ── Equipment: computers ───────────────────────────────────────────
    { key = "computer_t1", displayNameKey = "catalog.computer_t1",
      category = "equipment", footprint = { x = 4, z = 2 },
      allowedRotations = { 0, 180 }, themeId = nil,
      equipmentTier = 1, equipmentRole = "computer", equipmentScore = 10,
      baseCost = 50, colourSlots = {}, sourceAssetKey = "O.Computer1" },

    { key = "computer_t2", displayNameKey = "catalog.computer_t2",
      category = "equipment", footprint = { x = 6, z = 2 },
      allowedRotations = { 0, 180 }, themeId = nil,
      equipmentTier = 2, equipmentRole = "computer", equipmentScore = 16,
      baseCost = 200, colourSlots = {}, sourceAssetKey = "O.Computer2" },

    { key = "computer_t3", displayNameKey = "catalog.computer_t3",
      category = "equipment", footprint = { x = 6, z = 2 },
      allowedRotations = { 0, 180 }, themeId = nil,
      equipmentTier = 3, equipmentRole = "computer", equipmentScore = 22,
      baseCost = 500, colourSlots = {}, sourceAssetKey = "O.Computer3" },

    -- ── Equipment: lighting ────────────────────────────────────────────
    { key = "lighting_t1", displayNameKey = "catalog.lighting_t1",
      category = "equipment", footprint = { x = 2, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentTier = 1, equipmentRole = "lighting", equipmentScore = 8,
      baseCost = 25, colourSlots = {}, sourceAssetKey = "O.Light1" },

    { key = "lighting_t2", displayNameKey = "catalog.lighting_t2",
      category = "equipment", footprint = { x = 4, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentTier = 2, equipmentRole = "lighting", equipmentScore = 14,
      baseCost = 125, colourSlots = {}, sourceAssetKey = "O.Light2" },

    { key = "lighting_t3", displayNameKey = "catalog.lighting_t3",
      category = "equipment", footprint = { x = 4, z = 4 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentTier = 3, equipmentRole = "lighting", equipmentScore = 20,
      baseCost = 350, colourSlots = {}, sourceAssetKey = "O.Light3" },

    -- ── Decor (theme-agnostic) ─────────────────────────────────────────
    { key = "desk_basic", displayNameKey = "catalog.desk_basic",
      category = "decor", footprint = { x = 8, z = 4 },
      allowedRotations = { 0, 180 }, themeId = nil,
      equipmentScore = 0, baseCost = 20,
      colourSlots = { "primary", "secondary" }, sourceAssetKey = "A01.Desk" },

    { key = "chair_basic", displayNameKey = "catalog.chair_basic",
      category = "decor", footprint = { x = 2, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentScore = 0, baseCost = 10,
      colourSlots = { "primary", "secondary" }, sourceAssetKey = "A01.Chair" },

    { key = "shelf_basic", displayNameKey = "catalog.shelf_basic",
      category = "decor", footprint = { x = 4, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentScore = 0, baseCost = 25,
      colourSlots = { "primary" }, sourceAssetKey = "A01.Shelf" },

    { key = "plant_basic", displayNameKey = "catalog.plant_basic",
      category = "decor", footprint = { x = 2, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentScore = 0, baseCost = 15,
      colourSlots = { "pot" }, sourceAssetKey = "A01.Plant" },

    -- ── Decor (Vlog Loft) ──────────────────────────────────────────────
    { key = "sofa_coral", displayNameKey = "catalog.sofa_coral",
      category = "decor", footprint = { x = 6, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = "vlog_loft",
      equipmentScore = 0, baseCost = 35,
      colourSlots = { "seat", "frame" }, sourceAssetKey = "A01.Sofa" },

    { key = "coffee_table", displayNameKey = "catalog.coffee_table",
      category = "decor", footprint = { x = 4, z = 2 },
      allowedRotations = { 0, 180 }, themeId = "vlog_loft",
      equipmentScore = 0, baseCost = 20,
      colourSlots = { "top", "feet" }, sourceAssetKey = "A01.Table" },

    { key = "armchair_lounge", displayNameKey = "catalog.armchair_lounge",
      category = "decor", footprint = { x = 4, z = 2 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = "vlog_loft",
      equipmentScore = 0, baseCost = 30,
      colourSlots = { "seat", "frame" }, sourceAssetKey = "A01.Armchair" },

    { key = "rug_vlog", displayNameKey = "catalog.rug_vlog",
      category = "decor", footprint = { x = 10, z = 8 },
      allowedRotations = { 0 }, themeId = "vlog_loft",
      equipmentScore = 0, baseCost = 15,
      colourSlots = { "primary" }, sourceAssetKey = "O.Rug" },

    { key = "backdrop_vlog", displayNameKey = "catalog.backdrop_vlog",
      category = "decor", footprint = { x = 10, z = 1 },
      allowedRotations = { 0 }, themeId = "vlog_loft",
      equipmentScore = 0, baseCost = 25,
      colourSlots = { "field" }, sourceAssetKey = "O.Backdrop" },

    -- ── Decor (Gaming Den) ─────────────────────────────────────────────
    { key = "arcade_upright", displayNameKey = "catalog.arcade_upright",
      category = "decor", footprint = { x = 4, z = 4 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = "gaming_den",
      equipmentScore = 0, baseCost = 75,
      colourSlots = { "body", "accent" }, sourceAssetKey = "A02.Upright" },

    { key = "rug_gaming", displayNameKey = "catalog.rug_gaming",
      category = "decor", footprint = { x = 10, z = 8 },
      allowedRotations = { 0 }, themeId = "gaming_den",
      equipmentScore = 0, baseCost = 15,
      colourSlots = { "primary" }, sourceAssetKey = "O.Rug" },

    { key = "wall_panel_gaming", displayNameKey = "catalog.wall_panel_gaming",
      category = "decor", footprint = { x = 8, z = 1 },
      allowedRotations = { 0 }, themeId = "gaming_den",
      equipmentScore = 0, baseCost = 20,
      colourSlots = { "field" }, sourceAssetKey = "O.WallPanel" },

    -- ── Display ────────────────────────────────────────────────────────
    { key = "plinth_basic", displayNameKey = "catalog.plinth_basic",
      category = "display", footprint = { x = 4, z = 4 },
      allowedRotations = { 0, 90, 180, 270 }, themeId = nil,
      equipmentScore = 0, baseCost = 30,
      colourSlots = { "base", "accent" }, sourceAssetKey = "O.Plinth" },
}

local index: { [string]: Entry } = {}
for _, e in ipairs(ENTRIES) do
    if index[e.key] then
        error(("[CatalogConfig] duplicate key: %s"):format(e.key))
    end
    index[e.key] = e
end

function CatalogConfig.byKey(key: string): Entry?
    return index[key]
end

function CatalogConfig.all(): { Entry }
    return ENTRIES
end

function CatalogConfig.forTheme(themeId: string?): { Entry }
    local out: { Entry } = {}
    for _, e in ipairs(ENTRIES) do
        if e.themeId == nil or e.themeId == themeId then
            table.insert(out, e)
        end
    end
    return out
end

return CatalogConfig