local m_status_ok, lang_base = pcall(require, "user.languages.util.lang_base")
if not m_status_ok then 
  return
end

local c = lang_base:new{
  lsp_server = "clangd",
  formatter = "clang-format",
  diagnostics = "cpplint",
  has_server_extension = true,
  hook_fuction = require("clangd_extensions").prepare
}

return c
