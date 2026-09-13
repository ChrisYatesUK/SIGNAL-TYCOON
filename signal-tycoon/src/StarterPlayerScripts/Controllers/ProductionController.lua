--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="ProductionPanel",actions={
 ["production.quote"]=true,
 ["production.start"]=true,
 ["production.collect"]=true,
}})
