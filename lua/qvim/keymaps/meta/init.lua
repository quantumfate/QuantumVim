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
local util = require("qvim.keymaps.meta.util")
    .init(
        binding,
        group,
        keymap
    )

binding.init(util)
group.init(util)
keymap.init(util)
mode.init(util)

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
meta.mode = mode

return meta
