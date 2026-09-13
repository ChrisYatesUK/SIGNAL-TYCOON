--!strict
-- Screen-specific action boundary. Presentation is composed by UIRuntime from
-- the server display projection in UI-Data-Contract.md; no server state is modified.
return table.freeze({name="CrewPanel",actions={
 ["crew.hire"]=true,
 ["crew.level"]=true,
 ["crew.assign"]=true,
 ["crew.unassign"]=true,
}})
