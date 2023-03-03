---@class meta
local meta = {}

local keymap = require("qvim.keymaps.meta.keymap")

meta.keymap = keymap

local Log = require("qvim.integrations.log")
local fn = require("qvim.utils.fn")
local fn_t = require("qvim.utils.fn_t")
local default = require("qvim.keymaps.default")

local has_key = fn_t.has_any_key

meta.integration_base_mt = setmetatable({}, {
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

meta.keymap_independent_mt = setmetatable({}, {
    __newindex = function(t, key, other)
        local key_is_string = type(key) == "string"
        if key_is_string then
            t.keybindings = setmetatable(other.bindings or {}, { __index = meta.mode_adapter_mt })
        end
    end
})

--- A meta table that enforces a structure consisting at least of
---- group(string)
---- leader(string)
---- bindings(table)
meta.keymap_group_mt = setmetatable({}, {
    ---Organizes the structure
    ---@param t table
    ---@param other table
    __newindex = function(t, idx, other)
        local key_is_number = type(idx) == "number"
        local other_is_table = type(other) == "table"
        if key_is_number and other_is_table then
            if has_key(other, "name") and has_key(other, "key_group") and has_key(other, "prefix") and has_key(other, "bindings") then
                t = setmetatable(other or {}, { __index = default.keymap_group_opts })
                t.bindings = setmetatable(other.bindings or {}, { __index = M.mode_adapter_mt })
            else
                Log:error(string.format("Invalid whichkey group table '%s'", other))
            end
        else
            if not key_is_number then
                Log:error(string.format(
                    "The key must be an index and not '%s'. Tables in the kaymap group meta table do not have a dedicated key.",
                    type(idx)))
            end
            if not other_is_table then
                Log:error("Invalid element. A whichkey group must be a table.")
            end
        end
    end,
})

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
                t[mode_adapter] = setmetatable(other_keymap_t or {}, meta.binding_mt)
            else
                Log:error(string.format("Invalid mode adapter '%s'", other_keymap_t))
            end
        else
            Log:error(string.format("The value corresponding to the mode adapter '%s' must be a table.", mode_adapter))
        end
    end
})

---The binding meta table ensures that all keybindings are set correctly and additionally
---it will be ensured that all default options are set except for the user defined ones.
meta.binding_mt = setmetatable({}, {
    ---Returns the table indexed by the left hand side with defined options and populated defaults
    ---@param t table
    ---@param lhs string the left hand side of a keymap
    ---@return table keymap the keymap corresponding to the left hand side
    __index = function(t, lhs)
        if not t[lhs] then
            t[lhs] = setmetatable({}, { __index = keymap.opts_mt })
        end
        return t[lhs]
    end,
    ---Populates other with missing default options
    ---@param t table
    ---@param lhs string the left hand side of a keymap
    ---@param other table the keymap corresponding to the left hand side
    __newindex = function(t, lhs, other)
        local lhs_is_string = type(lhs) == "string" and not fn.isempty(lhs)
        local other_is_table = type(other) == "table"
        if lhs_is_string and other_is_table then
            local default_keymap_opts = setmetatable(other or {}, keymap.opts_mt)
            t[lhs] = default_keymap_opts
        else
            if not other_is_table then
                if lhs_is_string then
                    Log:error(string.format(
                        "The value corresponding to the left hand side of the keymap '%s' must be a table but is '%s'.",
                        lhs, type(other)))
                else
                    Log:error(string.format(
                        "The value corresponding to the left hand side of a keymap must be a table but is '%s'.",
                        type(other)))
                end
            end
            if not lhs_is_string then
            end
        end
    end
})

return meta
