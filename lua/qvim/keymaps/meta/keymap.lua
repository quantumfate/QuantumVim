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
keymap.mt = setmetatable({}, {
    ---Creates a new index in `t` and the value can in any case be either `keymap.opts_mt` or `keymap.opts_collection_mt`.
    ---When `getmetatable` of `t[lhs]` and `other` are identical an addition operation will be called on the tables.
    ---In case of different return values of `getmetatable` the appropriate action will be called to merge the existing `t[lhs]`
    ---with `other`.0
    ---@param t table
    ---@param lhs string
    ---@param other table
    __newindex = function(t, lhs, other)
        if type(lhs) == "string" then
            if type(other) == "table" then
                local binding = util.set_binding_mt(lhs, other)
                fn_t.rawset_debug(t, lhs, binding)
            else
                if t[lhs] then
                    Log:debug(string.format(
                        "An existing keymap associated with the lef hand side '%s' was overridden by defaults.", lhs))
                end
                fn_t.rawset_debug(t, lhs, util.set_binding_mt(lhs, {}))
            end
        elseif type(lhs) == "number" then
            fn_t.rawset_debug(t, lhs, util.process_group_mt(t, lhs, other))
        else
            Log:error(string.format("The left hand side of a binding must be a string but is '%s'", type(lhs)))
        end
    end
})


return keymap
