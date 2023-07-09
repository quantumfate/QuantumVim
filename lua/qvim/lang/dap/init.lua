---@class dap
local M = {}

function M.setup()
    require("qvim.integrations.dap.mason-dap"):setup()
    require("qvim.integrations.dap.ui"):setup()
    require("qvim.integrations.dap.virtual-text"):setup()
end

return M
