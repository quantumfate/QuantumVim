---@class yikes
local M = {}

local util = require("keymaps.adapters.util")

-- Helper function to set keymaps
local function set_keymap(mode, lhs, rhs, opts)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

-- Helper function to unset keymaps
local function unset_keymap(mode, lhs)
    vim.api.nvim_del_keymap(mode, lhs)
end

-- Function to apply keymaps of a specific group
local function apply_keymaps_for_group(group)
    local keymaps = qvim.keymaps[group]
    if keymaps then
        for _lhs, _binding in pairs(keymaps) do
            local mode, lhs, rhs, opts = util.keymap_unpack(_lhs, _binding)
            unset_keymap(mode, lhs)
        end
    end
end

-- Function to remove the keymaps of a specific group
local function remove_keymaps_for_group(group)
    local keymaps = qvim.keymaps[group]
    if keymaps then
        for _lhs, _binding in pairs(keymaps) do
            local mode, lhs, rhs, opts = util.keymap_unpack(_lhs, _binding)
            opts.buffer = 0                 -- Apply mappings to the current buffer only
            set_keymap(mode, lhs, "", opts) -- Clear the mapping by setting the rhs to an empty string
        end
    end
end


-- Function to call when the binding is activated
local function on_group_activation(group)
    apply_keymaps_for_group(group)
    vim.cmd("autocmd BufLeave,BufWinLeave <buffer> ++once lua remove_keymaps_for_group('" .. group .. "')")
    vim.cmd("autocmd InsertEnter <buffer> ++once lua remove_keymaps_for_group('" .. group .. "')")

    local original_esc_keymap = nil
    local current_keymaps = vim.api.nvim_get_keymap("n")
    for _, keymap in ipairs(current_keymaps) do
        if keymap.lhs == "<Esc>" then
            original_esc_keymap = keymap
            break
        end
    end

    if original_esc_keymap ~= nil then
        -- Custom mapping for escape key
        set_keymap("n", "<Esc>",
            ":lua vim.schedule(function() remove_keymaps_for_group('" ..
            group .. "'); restore_original_esc_keymap() end)<CR><Esc>", { noremap = true, silent = true })

        -- Function to restore the original escape key mapping
        _G.restore_original_esc_keymap = function()
            set_keymap("n", original_esc_keymap.lhs, original_esc_keymap.rhs, original_esc_keymap.options)
        end
    else
        -- Custom mapping for escape key if no original mapping exists
        set_keymap("n", "<Esc>", ":lua remove_keymaps_for_group('" .. group .. "')<CR><Esc>",
            { noremap = true, silent = true })
    end
end


function M.adapt()
    for descriptor, binding in pairs(qvim.keymaps) do

    end
end

return M
