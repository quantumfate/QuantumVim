---@class lang
local M = {}
local autocmds = require "qvim.core.autocmds"

function M.setup()
    require("qvim.lang.templates").generate_templates()

    require("qvim.lang.lsp").setup()
    require("qvim.lang.null-ls").setup()
    require("qvim.lang.dap").setup()

    autocmds.configure_format_on_save()
end

return M
