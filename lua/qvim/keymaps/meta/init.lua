---Initializes the meta section by requiring the necessary modules.
---@class meta
---@field binding function
---@field group function
---@field keymap function
---@field mode mode
local meta = {}

local binding = require("qvim.keymaps.meta.binding")
local group = require("qvim.keymaps.meta.group")
local keymap = require("qvim.keymaps.meta.keymap")
local mode = require("qvim.keymaps.meta.mode")
local descriptor = require("qvim.keymaps.meta.descriptor")
local util = require("qvim.keymaps.meta.util")
    .init(
        binding,
        group,
        keymap,
        mode,
        descriptor
    )

binding.init(util)
group.init(util)
keymap.init(util)
mode.init(util)
descriptor.init(util)

---Get a new binding metatable
---@param init table|nil
---@return table
meta.get_new_binding_mt = function(init)
    return util.get_new_binding_mt(init)
end

---Get a new group metatable
---@param init table|nil
---@return table
meta.get_new_group_mt = function(init)
    return util.get_new_group_mt(init)
end

---Get a new keymap metatable
---@param init table|nil
---@return table
meta.get_new_keymap_mt = function(init)
    return util.get_new_keymap_mt(init)
end

---Get a new mode metatable
---@param init table|nil
---@return table
meta.get_new_mode_mt = function(init)
    return util.get_new_mode_mt(init)
end

---Get a new mode metatable
---@param init table|nil
---@return table
meta.get_new_descriptor_mt = function(init)
    return util.get_new_descriptor_mt(init)
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
