--!strict
-- Canonical remote contract. Server creates remotes from this list at boot;
-- clients require this module only for names.

local RemoteDefinitions = {}

RemoteDefinitions.FolderName = "SignalTycoonRemotes"

RemoteDefinitions.Events = {
    RequestPlacement   = { direction = "C2S", args = { "catalogKey:string", "position:Vector3Data", "rotationY:number" } },
    RequestMove        = { direction = "C2S", args = { "placementId:string", "position:Vector3Data", "rotationY:number" } },
    RequestStore       = { direction = "C2S", args = { "placementId:string" } },
    RequestRecolour    = { direction = "C2S", args = { "placementId:string", "colourSlot:string" } },

    RequestStartJob    = { direction = "C2S", args = { "categoryId:string", "assignedCrewIds:{string}", "snapshotPlacementIds:{string}" } },
    RequestCollectJob  = { direction = "C2S", args = { "jobId:string" } },

    RequestHireCrew    = { direction = "C2S", args = { "role:CrewRole" } },
    RequestRebirth     = { direction = "C2S", args = {} },

    SubmitReport       = { direction = "C2S", args = { "reportType:string", "targetUserId:number", "reason:string", "context:string?" } },
    BlockPlayer        = { direction = "C2S", args = { "targetUserId:number" } },
    UnblockPlayer      = { direction = "C2S", args = { "targetUserId:number" } },

    ProfileReplicated  = { direction = "S2C", args = { "profile:PublicProfile" } },
    ProfileDelta       = { direction = "S2C", args = { "patch:{}" } },
    JobStateChanged    = { direction = "S2C", args = { "job:ProductionJob" } },
    ActionResult       = { direction = "S2C", args = { "actionId:string", "ok:boolean", "reason:string?" } },
    ToastMessage       = { direction = "S2C", args = { "severity:string", "message:string" } },
}

RemoteDefinitions.Functions = {
    GetPublicProfile  = { direction = "C2S", returns = "PublicProfile" },
    GetCatalog        = { direction = "C2S", returns = "{CatalogEntry}" },
}

return RemoteDefinitions
