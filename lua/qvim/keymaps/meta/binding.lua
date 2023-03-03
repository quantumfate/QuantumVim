---@class binding
local binding = {}

local keymap = require("qvim.keymaps.meta.keymap")
local fn = require("qvim.utils.fn")
local Log = require("qvim.integrations.log")

---The binding meta table ensures that all keybindings are set correctly and additionally
---it will be ensured that all default options are set except for the user defined ones.
binding.lhs_to_keymap_mt = setmetatable({}, {
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
    __newindex = function(t, lhs, other, ...)
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
                Log:error(string.format(
                    "The left hand side of a keymap must be a string but is '%s'.",
                    type(lhs)))
            end
        end
    end
})

return binding
