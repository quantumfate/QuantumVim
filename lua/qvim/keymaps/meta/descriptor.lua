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

---A predicate to verify that the `tostring` call of a given
---`_binding` equals `_descriptor`.
---@param _descriptor string
---@param _binding binding
---@return boolean
local function predicate(_descriptor, _binding)
    return _descriptor == tostring(_binding)
end

---The metatable to group keymaps by a descriptor.
descriptor.mt = setmetatable({}, {
    ---A keymap table added to this table will filter the bindings filtered and grouped by the descriptor.
    ---@param t table
    ---@param _descriptor string
    ---@param _binding table
    __newindex = function(t, _descriptor, _binding)
        if type(_descriptor) == "string" then
            if type(_binding) == "table" then
                local keymaps = util.process_keymap_mt(_descriptor,
                    { filter = predicate, condition = _descriptor, _binding })
                fn_t.rawset_debug(t, _descriptor, keymaps)
            else
                Log:error(string.format("The value corresponding to a descriptor '%s' must be a table.", _descriptor))
            end
        else
            Log:error(string.format("The descriptor of the keymap '%s' must be a string but was '%s'",
                getmetatable(_binding), type(_descriptor)))
        end
    end
})

return descriptor
