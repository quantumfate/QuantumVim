local cpp = {
  lsp_server = "clangd",
  formatter = "clang-format",
  diagnostics = "cpplint",
  server_extension = true,
  hook_function = require("clangd_extensions").prepare
}

return cpp
