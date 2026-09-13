--!strict
return table.freeze({
 Surface=Color3.fromRGB(241,245,249), Raised=Color3.fromRGB(226,232,240),
 Ink=Color3.fromRGB(30,41,59), Muted=Color3.fromRGB(71,85,105),
 Primary=Color3.fromRGB(34,211,238), Brand=Color3.fromRGB(139,92,246),
 Coral=Color3.fromRGB(251,113,133), Danger=Color3.fromRGB(153,27,27),
 DangerFill=Color3.fromRGB(254,226,226),
 Body=Enum.Font.Gotham, Bold=Enum.Font.GothamBold, Heading=Enum.Font.GothamBlack,
 BodySize=16, SmallSize=14, HeadingSize=20, Target=48,
 Rarity={
  Common={colour=Color3.fromRGB(148,163,184),shape="circle",fallback="●",key="rarity.common"},
  Uncommon={colour=Color3.fromRGB(34,197,94),shape="triangle",fallback="▲",key="rarity.uncommon"},
  Rare={colour=Color3.fromRGB(59,130,246),shape="diamond",fallback="◆",key="rarity.rare"},
  Epic={colour=Color3.fromRGB(168,85,247),shape="star",fallback="★",key="rarity.epic"},
 },
 Motion={press=0.08,panel=0.16,reveal=0.45},
})
