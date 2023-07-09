local M = {}

local Log = require "qvim.log"

---Replaces hyphons with underscores in a string
---@param val string|nil
function M.normalize(val)
    if val and type(val) == "string" then
        if not string.find(val, "-") then
            return val
        end
        return val:gsub("-", "_")
    end
    return val
end

---Recursively creates a shallow copy of a given table
---@param t table
---@return table
function M.shallow_table_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = M.shallow_table_copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---Checks if s is empty or nil
---@param s string
---@return boolean
function M.isempty(s)
    return s == nil or s == ""
end

function M.get_buf_option(opt)
    local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
    if not status_ok then
        return nil
    else
        return buf_option
    end
end

return M
