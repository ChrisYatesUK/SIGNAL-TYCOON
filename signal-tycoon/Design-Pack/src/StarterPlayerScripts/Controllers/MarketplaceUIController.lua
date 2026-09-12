--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="MarketplaceHub",actions={
 ["market.query"]=true,
 ["market.list"]=true,
 ["market.cancel"]=true,
 ["market.offer"]=true,
 ["market.accept"]=true,
 ["market.review"]=true,
 ["market.confirm"]=true,
 ["market.visit"]=true,
 ["market.return"]=true,
}})
