--!strict
-- Deterministic rarity bands per v2.0 MVP. Thresholds inclusive-lower.

export type RarityBand = {
    id: "Common" | "Uncommon" | "Rare" | "Epic",
    min: number,
    max: number,
    colour: string,
    shape: string,
}

local RarityConfig = {}

RarityConfig.Bands = {
    { id = "Common",   min = 0,   max = 40,   colour = "#94A3B8", shape = "circle"   },
    { id = "Uncommon", min = 40,  max = 60,   colour = "#22C55E", shape = "triangle" },
    { id = "Rare",     min = 60,  max = 80,   colour = "#3B82F6", shape = "diamond"  },
    { id = "Epic",     min = 80,  max = 101,  colour = "#A855F7", shape = "star"     },
} :: { RarityBand }

function RarityConfig.forQuality(quality: number): string
    for _, band in ipairs(RarityConfig.Bands) do
        if quality >= band.min and quality < band.max then
            return band.id
        end
    end
    return "Common"
end

return RarityConfig
