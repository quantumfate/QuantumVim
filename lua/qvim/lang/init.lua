---@class lang
local M = {}
local utils = require "qvim.utils"
local autocmds = require "qvim.core.plugins.autocmds"

function M.setup()
    if in_headless_mode() then
        return
    end
    if not utils.is_directory(qvim.lsp.templates_dir) then
        require("qvim.lang.templates").generate_templates()
    end
    require("qvim.lang.lsp").setup()
    require("qvim.lang.null-ls").setup()
    require("qvim.lang.dap").setup()

    autocmds.configure_format_on_save()
end

return M
