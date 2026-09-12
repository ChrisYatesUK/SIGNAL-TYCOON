--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="BuildCatalogue",actions={
 ["build.select"]=true,
 ["build.place"]=true,
 ["build.move"]=true,
 ["build.recolour"]=true,
 ["build.store"]=true,
 ["build.theme"]=true,
 ["build.rotate"]=true,
 ["build.north"]=true,
 ["build.south"]=true,
 ["build.east"]=true,
 ["build.west"]=true,
 ["build.cancelPreview"]=true,
 ["build.submitPreview"]=true,
}})
