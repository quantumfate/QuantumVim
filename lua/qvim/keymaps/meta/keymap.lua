--- yet (another) innovative keymap enabling setter
---@class keymap
local keymap = {}
local Log = require("qvim.integrations.log")
local fn_t = require("qvim.utils.fn_t")

---@class util
local util = nil

---initializes the keymap module with the util factory
---@param _util util
---@return keymap
function keymap.init(_util)
    util = _util
    return keymap
end

--- The metatable for keymaps. A left hand side will be bound to a `keymap.opts_mt` table.
keymap.mt = {
    __index = function(t, lhs)
        if type(lhs) == "string" then
            return t[lhs]
        else
            Log:error(string.format(
                "Failed to index keymap. The left hand side of a binding must be a string but is '%s'", type(lhs)))
        end
    end,
    ---Creates a new index in `t` and the value can in any case be either `keymap.opts_mt` or `keymap.opts_collection_mt`.
    ---When `getmetatable` of `t[lhs]` and `other` are identical an addition operation will be called on the tables.
    ---In case of different return values of `getmetatable` the appropriate action will be called to merge the existing `t[lhs]`
    ---with `other`.0
    ---@param t table
    ---@param lhs string
    ---@param other table
    __newindex = function(t, lhs, other)
        if type(lhs) == "string" then
            if g_yikes_current_standalone_bindings[lhs] then
                Log:warn(string.format("An existing standalone keymap with the left hand side '%s' will be overwritten.",
                    lhs))
            end
            if type(other) == "table" then
                local binding = util.set_binding_mt(lhs, other, nil)
                fn_t.rawset_debug(t, lhs, binding)
            else
                print("val: ", other)
                error(string.format("Error creating binding '%s'! A binding must have a table value but was '%s'.", lhs,
                    type(other)))
            end
        else
            Log:error(string.format("The left hand side of a binding must be a string but is '%s'", type(lhs)))
        end
    end
}


return keymap
