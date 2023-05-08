---@class descriptor
local descriptor = {}

local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")

---@class util
local util = nil

---initializes the binding module with the util factory
---@param _util util
---@return descriptor
function descriptor.init(_util)
    util = _util
    return descriptor
end

---The metatable to group keymaps by a descriptor.
descriptor.mt = {
    ---A keymap table added to this table will filter the bindings filtered and grouped by the descriptor.
    ---@param t table
    ---@param _descriptor string
    ---@param _keymaps table
    __newindex = function(t, _descriptor, _keymaps)
        if type(_descriptor) == "string" then
            if type(_keymaps) == "table" then
                if string.match(_descriptor, "^binding=.*$") then
                    fn_t.rawset_debug(t, _descriptor, util.process_keymap_mt(_descriptor, _keymaps))
                elseif string.match(_descriptor, "^key_group=.*$") then
                    fn_t.rawset_debug(t, _descriptor, util.process_group_mt(t, _descriptor, _keymaps))
                else
                    Log:error(string.format("Unsupported  descriptor '%s'.", _descriptor))
                end
            else
                Log:error(string.format("The value corresponding to a descriptor '%s' must be a table.", _descriptor))
            end
        else
            Log:error(string.format("The descriptor of the keymap '%s' must be a string but was '%s'",
                getmetatable(_keymaps), type(_descriptor)))
        end
    end
}

return descriptor
