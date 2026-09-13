--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="PartnershipPanel",actions={
 ["partnership.request"]=true,
 ["partnership.accept"]=true,
 ["partnership.decline"]=true,
 ["partnership.vote"]=true,
 ["partnership.dissolveQuote"]=true,
 ["partnership.dissolve"]=true,
}})
