---@class adapters
local M = {}
local adapt_yikes = require("qvim.keymaps.adapters.yikes")
local adapt_whichkey = require("qvim.keymaps.adapters.whichkey")

---Adapt the current state of keybindings for the available keymap plugin
---@param bindings table|nil
function M.setup(bindings)
    local whichkey_status, whichkey = pcall(require, "which-key")

    if whichkey_status then
        adapt_whichkey.adapt(whichkey, bindings)
    else
        adapt_yikes.adapt()
    end
end

return M
