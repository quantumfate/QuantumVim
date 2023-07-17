---@class tree-climber : nvim-treesitter
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: tree-climber, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: tree-climber)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: tree-climber, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local tree_climber = {
    enabled = true,
    name = nil,
    options = {},
    keymaps = {
        --[[         ["H"] = { callback = require("tree-climber").goto_parent, desc = "Climb to parent node." },
        ["L"] = { callback = require("tree-climber").goto_child, desc = "Climb to child node." },
        ["J"] = { callback = require("tree-climber").goto_next, desc = "Climb to next node." },
        ["K"] = { callback = require("tree-climber").goto_prev, desc = "Climb to previous node." },
        ["<c-k>"] = {
            callback = require("tree-climber").swap_prev,
            desc = "Swap current with previous node.",
        },
        ["<c-j>"] = {
            callback = require("tree-climber").swap_next,
            desc = "Swap current with next node.",
        },
        ["<c-h>"] = {
            callback = require("tree-climber").highlight_node,
            desc = "Highlight current node",
        }, ]]
    },
    main = nil,
    on_setup_start = nil,
    setup_ext = nil,
    on_setup_done = nil,
    url = "https://github.com/drybalka/tree-climber.nvim",
}

tree_climber.__index = tree_climber

return tree_climber
