local M = {}

-- The metatable for the tracking proxy
local mt = {
    __index = function(t, k)
        print("* access to element " .. tostring(k))
        return t.__inner[k] -- Access the original table
    end,
    __newindex = function(t, k, v)
        print("* update of element " .. tostring(k) .. " to " .. tostring(v))
        t.__inner[k] = v -- Update the original table
    end
}
---Tracks the access to a table t
---@param t table table where accesses should be forwarded to
---@return table proxy the proxy that forwards accesses to the table t
function M.track(t)
    local proxy = setmetatable({}, mt)
    proxy.__inner = t
    return proxy
end

return M
