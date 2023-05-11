---@class util
local M = {}

--- credits: https://github.com/folke/which-key.nvim
function M.get_mode()
    local mode = vim.api.nvim_get_mode().mode
    return mode:lower()
end

---Unpacks a keymap.
---@param lhs string
---@param binding table
---@return string mode, string lhs, string rhs, table options
function M.keymap_unpack(lhs, binding)
    local options = {}
    for key, value in pairs(binding) do
        if key ~= "mode" and key ~= "rhs" then
            options[key] = value
        end
    end
    return binding.mode, lhs, binding.rhs, options
end

return M
