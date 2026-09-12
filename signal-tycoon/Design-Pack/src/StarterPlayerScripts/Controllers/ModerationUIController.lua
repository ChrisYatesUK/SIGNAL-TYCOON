--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="ReportDialog",actions={
 ["moderation.report"]=true,
 ["moderation.block"]=true,
 ["moderation.unblock"]=true,
}})
