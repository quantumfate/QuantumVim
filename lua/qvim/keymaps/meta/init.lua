---Initializes the meta section by requiring the necessary modules.
---@class meta
---@field binding binding
---@field group group
---@field keymap keymap
---@field descriptor descriptor
local meta = {}

local util, binding, group, keymap, descriptor = require("qvim.keymaps.meta.util")
    .init(
        "qvim.keymaps.meta.binding",
        "qvim.keymaps.meta.group",
        "qvim.keymaps.meta.keymap",
        "qvim.keymaps.meta.descriptor"
    )

binding.init(util)
group.init(util)
keymap.init(util)
descriptor.init(util)

---Get a new proxy  binding metatable
---@param init table|nil
---@return table
meta.get_new_binding_proxy_mt = function(init)
    return util.get_new_binding_proxy_mt(init)
end


---Get a new proxy keymap metatable
---@param init table|nil
---@return table
meta.get_new_keymap_proxy_mt = function(init)
    return util.get_new_keymap_proxy_mt(init)
end

---Get a new proxy mode metatable
---@param init table|nil
---@return table
meta.get_new_descriptor_proxy_mt = function(init)
    return util.get_new_descriptor_proxy_mt(init)
end

---Ensures that the given table `_binding` is a table of `binding.mt` with accepted options.
---The key, value pair assigment for the returned table will be delegated to the `__newindex`
---method of `binding.mt`. Skips the process when a given `_binding` already has the necessary
---meta information.
---@param _lhs string the left hand side `_binding` will be associated with
---@param _binding table the binding
---@param _options table|nil manually set options - options in `_binding` have precedence
---@return table table the binding with accepted options with the metatable `binding.mt`
meta.set_binding_mt = function(_lhs, _binding, _options)
    return util.set_binding_mt(_lhs, _binding, _options)
end

return meta
