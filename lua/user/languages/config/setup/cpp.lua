local cpp = {
  lsp_server = "clangd",
  formatter = "clang-format",
  diagnostics = "cpplint",
  has_server_extension = true,
  hook_fuction = require("clangd_extensions").prepare
}

return cpp
