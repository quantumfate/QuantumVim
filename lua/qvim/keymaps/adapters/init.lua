---@class adapters
local M = {}
local adapt_yikes = require("qvim.keymaps.adapters.yikes")
local adapt_whichkey = require("qvim.keymaps.adapters.whichkey")

---Adapt the current state of keybindings for the available keymap plugin
function M.setup()
    local whichkey_status, whichkey = pcall(require, "which-key")
    print("whichkey_status: ", whichkey_status)

    if whichkey_status then
        adapt_whichkey.adapt(whichkey)
    else
        adapt_yikes.adapt()
    end
end

return M
