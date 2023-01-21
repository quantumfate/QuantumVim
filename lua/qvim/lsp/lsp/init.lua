M = {}
local utils = require("qvim.utils.util")
M.lsp_config = require("qvim.languages.lsp.lspconfig")
utils:require_module("qvim.languages.lsp.nlspsettings")
utils:require_module("qvim.languages.lsp.null-ls")

return M
