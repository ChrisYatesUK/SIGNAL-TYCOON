--!strict
-- Small helpers. Deep copy is used by the profile store.

local TableUtil = {}

function TableUtil.deepCopy<T>(value: T): T
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value :: any) do
        copy[TableUtil.deepCopy(k)] = TableUtil.deepCopy(v)
    end
    return copy :: T
end

function TableUtil.count<T>(t: { [any]: T }): number
    local n = 0
    for _ in pairs(t) do n += 1 end
    return n
end

return TableUtil
