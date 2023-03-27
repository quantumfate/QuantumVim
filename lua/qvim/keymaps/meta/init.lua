---@class meta
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

meta.binding = binding
meta.group = group
meta.keymap = keymap
meta.mode = mode

return meta
