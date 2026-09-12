--!strict
-- Canonical type definitions. Server and client both require this module.
-- No runtime logic.

export type Vector3Data = { x: number, y: number, z: number }

export type CrewRole = "Editor" | "CameraOperator" | "TalentScout" | "CommunityManager"

export type CrewMember = {
    id: string,
    role: CrewRole,
    level: number,
    xp: number,
    assignedJobId: string?,
}

export type Placement = {
    placementId: string,
    catalogKey: string,
    position: Vector3Data,
    rotationY: number,
    colourSlot: string?,
}

export type ProductionState = "Idle" | "Rendering" | "Ready" | "Collected" | "Cancelled"

export type ProductionJob = {
    jobId: string,
    category: string,
    quality: number,
    state: ProductionState,
    startedAt: number,
    completesAt: number,
    collectedAt: number?,
    snapshot: {
        equipmentScore: number,
        crewScore: number,
        themeScore: number,
        categoryId: string,
        assignedCrewIds: { string },
    },
    provisionalRarity: string,
    finalRarity: string?,
    settlementVersion: number?,
}

export type PartnershipRecord = {
    partnerUserId: number,
    role: "Host" | "Coowner",
    formedAt: number,
    creditsContributed: number,
    pendingUpgradeVote: {
        upgradeId: string,
        initiatedBy: number,
        expiresAt: number,
    }?,
}

export type ModerationFlag = {
    reason: string,
    timestamp: number,
    source: string,
}

export type PlayerSettings = {
    blockList: { number },
    tradeSafetyCompleted: boolean,
    reducedEffects: boolean,
    locale: string,
}

export type PlayerProfile = {
    schemaVersion: number,
    userId: number,
    displayName: string,
    credits: number,
    followers: number,
    rebirthLevel: number,
    rebirthHistory: { { level: number, timestamp: number } },
    unlocks: { [string]: boolean },
    crew: { [string]: CrewMember },
    placements: { [string]: Placement },
    jobs: { [string]: ProductionJob },
    activeJobId: string?,
    tutorialState: string,
    collectionIndex: { [string]: "active" | "archived" | "burned" },
    processedOperationIds: { [string]: boolean },
    partnership: PartnershipRecord?,
    settings: PlayerSettings,
    moderation: {
        reportCount: number,
        lastReportAt: number?,
        flags: { ModerationFlag },
    },
    _session: {
        leaseId: string?,
        lastSavedAt: number,
        loadedAt: number,
    },
}

export type PublicProfile = {
    userId: number,
    displayName: string,
    credits: number,
    followers: number,
    rebirthLevel: number,
    unlocks: { [string]: boolean },
    crew: { [string]: CrewMember },
    placements: { [string]: Placement },
    activeJob: ProductionJob?,
    tutorialState: string,
    partnership: PartnershipRecord?,
    settings: PlayerSettings,
}

export type CatalogEntry = {
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

export type TrendCategory = {
    id: string,
    displayName: string,
    baseInterest: number,
}

return {}
