local M = {}

local Log = require "qvim.log"

function M.setup()
    Log:debug "Setting up null-ls"

    local mason_null_ls_ok, _ = pcall(require, "mason-null-ls")
    if not mason_null_ls_ok then
        Log:error "Missing mason-null-ls dependency"
        return
    end

    local null_ls_ok, null_ls = pcall(require, "null-ls")
    if not null_ls_ok then
        Log:error "Missing null-ls dependency"
        return
    end

    local default_opts = require("qvim.lang.lsp").get_common_opts()
    vim.diagnostic.config {
        update_in_insert = qvim.lsp.null_ls.setup.update_in_insert,
    }
    null_ls.setup(
        vim.tbl_deep_extend(
            "force",
            default_opts,
            qvim.lsp.null_ls.setup,
            { sources = null_ls.builtins.code_actions.gitsigns }
        )
    )
end

return M
