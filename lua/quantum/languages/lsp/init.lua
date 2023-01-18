M = {}
local utils = require("quantum.utils.util")
M.lsp_config = require("quantum.languages.lsp.lspconfig")
utils:require_module("quantum.languages.lsp.nlspsettings")
utils:require_module("quantum.languages.lsp.null-ls")

return M
