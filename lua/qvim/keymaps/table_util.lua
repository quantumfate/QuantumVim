---Util for table related operations
---@class keymap.table_util
local table_util = {}

---Makes a given table read only by returning a proxy table that indexes the given table.
---@param t table
---@param callable function
---@return table proxy
function table_util.read_only(t, callable)
    local proxy = {}
    local mt = {
        __index = t,
        __newindex = callable,
        __pairs = function(_)
            return pairs(t)
        end,
    }
    setmetatable(proxy, mt)
    return proxy
end

return table_util
