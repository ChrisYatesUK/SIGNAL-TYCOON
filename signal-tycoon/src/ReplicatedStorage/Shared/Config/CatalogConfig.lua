--!strict
-- Placeable catalogue. MVP includes a small set; M2 expands to ~25 entries.

export type Entry = {
    key: string,
    displayName: string,
    category: "equipment" | "decor" | "display",
    footprint: { x: number, z: number },
    allowedRotations: { number },
    themeId: string?,
    equipmentTier: number?,
    equipmentRole: "camera" | "computer" | "lighting"?,
    baseCost: number,
    colourSlots: { string },
}

local CatalogConfig = {}

local ENTRIES: { Entry } = {
    -- Equipment
    { key = "camera_t1",   displayName = "Starter Camera",   category = "equipment",
      footprint = { x = 2, z = 2 }, allowedRotations = { 0, 90, 180, 270 },
      equipmentTier = 1, equipmentRole = "camera", baseCost = 0, colourSlots = {} },
    { key = "computer_t1", displayName = "Starter PC",       category = "equipment",
      footprint = { x = 2, z = 2 }, allowedRotations = { 0, 90, 180, 270 },
      equipmentTier = 1, equipmentRole = "computer", baseCost = 50, colourSlots = {} },
    { key = "lighting_t1", displayName = "Ring Light",       category = "equipment",
      footprint = { x = 2, z = 2 }, allowedRotations = { 0, 90, 180, 270 },
      equipmentTier = 1, equipmentRole = "lighting", baseCost = 25, colourSlots = {} },

    -- Decor (MVP placeholder; M2 replaces with Kenney-derived entries)
    { key = "decor_chair", displayName = "Studio Chair",     category = "decor",
      footprint = { x = 2, z = 2 }, allowedRotations = { 0, 90, 180, 270 },
      baseCost = 10, colourSlots = { "primary", "secondary" } },
    { key = "decor_desk",  displayName = "Studio Desk",      category = "decor",
      footprint = { x = 4, z = 2 }, allowedRotations = { 0, 180 },
      baseCost = 20, colourSlots = { "primary" } },
    { key = "decor_rug",   displayName = "Rug",              category = "decor",
      footprint = { x = 4, z = 4 }, allowedRotations = { 0 },
      baseCost = 15, colourSlots = { "primary" } },

    -- Display
    { key = "plinth_t1",   displayName = "Signal Drop Plinth", category = "display",
      footprint = { x = 2, z = 2 }, allowedRotations = { 0, 90, 180, 270 },
      baseCost = 30, colourSlots = { "accent" } },
}

local index: { [string]: Entry } = {}
for _, e in ipairs(ENTRIES) do
    index[e.key] = e
end

function CatalogConfig.byKey(key: string): Entry?
    return index[key]
end

function CatalogConfig.all(): { Entry }
    return ENTRIES
end

return CatalogConfig
