---@class meta
local meta = {}

local keymap = require("qvim.keymaps.meta.keymap")

meta.keymap = keymap

local Log = require("qvim.integrations.log")
local fn = require("qvim.utils.fn")
local fn_t = require("qvim.utils.fn_t")
local default = require("qvim.keymaps.default")

local has_key = fn_t.has_any_key

---The meta table that holds values grouped by keymap mode adapters
meta.mode_adapter_mt = setmetatable({}, {
    ---A key added to this table has to be one of the accepted mode adapters
    ---@param t table
    ---@param mode_adapter string
    ---@param other_keymap_t table
    __newindex = function(t, mode_adapter, other_keymap_t)
        if type(other_keymap_t) == "table" then
            local modes = vim.deepcopy(keymap_mode_adapters)
            for _mode_adapter, _ in pairs(modes) do
                modes[_mode_adapter] = true
            end
            if modes[mode_adapter] then
                t[mode_adapter] = setmetatable(other_keymap_t or {}, keymap.mt)
            else
                Log:error(string.format("Invalid mode adapter '%s'", other_keymap_t))
            end
        else
            Log:error(string.format("The value corresponding to the mode adapter '%s' must be a table.", mode_adapter))
        end
    end
})

return meta
