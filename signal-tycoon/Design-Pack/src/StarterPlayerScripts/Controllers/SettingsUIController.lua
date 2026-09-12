--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="Settings",actions={
 ["settings.toggle"]=true,
 ["settings.quieter"]=true,
 ["settings.louder"]=true,
 ["settings.save"]=true,
 ["moderation.unblock"]=true,
}})
