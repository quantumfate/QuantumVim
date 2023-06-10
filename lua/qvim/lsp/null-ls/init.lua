local M = {}

local Log = require "qvim.integrations.log"

function M.setup()
  local mason_null_ls_ok, mason_null_ls = pcall(require, "mason-null-ls")
  if not mason_null_ls_ok then
    Log:error("Missing mason-null-ls dependency")
    return
  end

  local null_ls_ok, null_ls = pcall(require, "null-ls")
  if not null_ls_ok then
    Log:error "Missing null-ls dependency"
    return
  end

  local default_opts = require("qvim.lsp").get_common_opts()
  null_ls.setup(vim.tbl_deep_extend("force", default_opts, qvim.lsp.null_ls.setup))
end

return M
