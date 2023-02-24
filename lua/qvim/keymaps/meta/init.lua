---@class meta
local M = {}

local default = require("qvim.keymaps.meta.default")

local Log = require "qvim.integrations.log"
local fn = require("qvim.utils.fn")
local fn_t = require("qvim.utils.fn_t")

local has_key = fn_t.has_any_key

M.integration_base_mt = setmetatable({}, {
    __index = function(t, k)
        local default_values = {
            active = true,
            on_config_done = nil,
            keymaps = {},
            options = {},
        }
        return default_values[k]
    end,
})

--- A meta table that enforces a structure consisting of
---- group(string)
---- leader(string)
---- bindings(table)
M.keymaps_group_mt = setmetatable({}, {
    ---Organizes the structure
    ---@param t table
    ---@param other table
    __newindex = function(t, other)
        if type(other) == "table" then
            if has_key(other, "group") and has_key(other, "leader") and has_key(other, "bindings") then
                t.group = other.group
                t.leader = other.leader
                t.bindings = setmetatable(other.bindings or {}, M.mode_adapter_mt)
            else
                Log:error(string.format("Invalid whichkey group table '%s'", other))
            end
        else
            Log:error("Invalid element. A whichkey group must be a table.")
        end
    end,
})

---The meta table that holds values grouped by keymap mode adapters
M.mode_adapter_mt = setmetatable({}, {
    ---A key added to this table has to be one of the accepted mode adapters
    ---@param t table
    ---@param k string
    ---@param v table
    __newindex = function(t, k, v)
        local modes = vim.deepcopy(keymap_mode_adapters)
        for key, _ in pairs(modes) do
            modes[key] = true
        end
        if modes[k] then
            t[k] = setmetatable(v or {}, M.keymap_mt)
        else
            Log:error(string.format("Invalid mode adapter '%s'", k))
        end
    end
})

M.keymap_mt = setmetatable({}, {
    __index = function(t, k)
        return t[k]
    end,
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end
})

return M
