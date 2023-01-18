M = {}
local utils = require("user.utils.util")
M.lsp_config = require("user.languages.lsp.lspconfig")
utils:require_module("user.languages.lsp.nlspsettings")
utils:require_module("user.languages.lsp.null-ls")

return M
