---@class adapters
local M = {}

---Adapt the current state of keybindings for the available keymap plugin
function M.setup()
    local whichkey_status, whichkey = pcall(require, "which-key")

    if whichkey_status then
        -- TODO: call whichkey
    else
        -- TODO: call yikes
    end
end

return M
