---@class yikes
local M = {}

local util = require("qvim.keymaps.adapters.util")
local shared_util = require("qvim.keymaps.util")
local constants = require("qvim.keymaps.constants")

---Helper function to set a kaymap or a buffer local keymap.
---@param mode string
---@param lhs string
---@param rhs string
---@param opts table
local function set_keymap(mode, lhs, rhs, opts)
    if opts.buffer then
        local temp_buffer = opts[constants.neovim_options_constants.buffer]
        opts[constants.neovim_options_constants.buffer] = nil
        vim.api.nvim_buf_set_keymap(temp_buffer, mode, lhs, rhs, opts)
        rawset(opts, constants.neovim_options_constants.buffer, temp_buffer) -- this is essential to be able to delete a buffer local mapping
    else
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
end

---Helper function to delete a keymap or a buffer local keymap.
---@param mode string
---@param lhs string
---@param buffer number|nil
local function unset_keymap(mode, lhs, buffer)
    if buffer then
        vim.api.nvim_buf_del_keymap(buffer, mode, lhs)
    else
        vim.api.nvim_del_keymap(mode, lhs)
    end
end

---Apply keymaps for a group.
---@param group table
local function apply_keymaps_for_group(group)
    local keymaps = qvim.keymaps[group]
    if keymaps then
        for _lhs, _binding in pairs(keymaps) do
            local mode, lhs, rhs, opts = util.keymap_unpack(_lhs, _binding)
            set_keymap(mode, lhs, rhs, opts)
        end
    end
end

---Remove keymaps of a group.
---@param group table
local function remove_keymaps_for_group(group)
    local keymaps = qvim.keymaps[group]
    if keymaps then
        for _lhs, _binding in pairs(keymaps) do
            local mode, lhs, rhs, opts = util.keymap_unpack(_lhs, _binding)
            opts.buffer = 0                      -- Apply mappings to the current buffer only
            unset_keymap(mode, lhs, opts.buffer) -- Clear the mapping by setting the rhs to an empty string
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
        shared_util.action_based_on_descriptor(
            descriptor,
            function()
                for _lhs, _opts in pairs(binding) do
                    local mode, lhs, rhs, opts = util.keymap_unpack(_lhs, _opts)
                    set_keymap(mode, lhs, rhs, opts)
                end
            end,
            function()
                -- TODO: implement groups with global variable
            end
        )
    end
end

return M
