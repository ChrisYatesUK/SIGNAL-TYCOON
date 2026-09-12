--!strict
-- Economy tuning. Salvage, tax, floors, and caps.

local EconomyConfig = {}

-- MVP: salvage grants a small Credit reward for non-tradable souvenirs.
EconomyConfig.SalvageCreditByRarity = {
    Common   = 5,
    Uncommon = 15,
    Rare     = 40,
    Epic     = 100,
}

-- V2B: Credit-denominated trade tax, burned (not redistributed).
EconomyConfig.MarketplaceTaxPercent = 0.05

-- V2B: price floors/ceilings per rarity band, in Credits.
EconomyConfig.CreditPriceFloor = { Common = 10,  Uncommon = 50,  Rare = 250,  Epic = 1000 }
EconomyConfig.CreditPriceCeil  = { Common = 500, Uncommon = 2500, Rare = 10000, Epic = 50000 }

-- Weekly cap shared across all plots and rebirths (v2.0 section 6).
EconomyConfig.WeeklyProductionCap = 56

return EconomyConfig
