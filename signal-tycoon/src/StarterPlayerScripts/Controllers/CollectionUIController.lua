--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="CollectionPanel",actions={
 ["collection.query"]=true,
 ["collection.select"]=true,
 ["collection.favourite"]=true,
 ["collection.salvageQuote"]=true,
 ["collection.salvage"]=true,
}})
