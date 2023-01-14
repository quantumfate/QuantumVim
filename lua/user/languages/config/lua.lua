local m_status_ok, lang_base = pcall(require, "user.languages.util.lang_base")
if not m_status_ok then 
  return
end

local lua = lang_base:new{
  lsp_server = "sumneko_lua",
  formatter = "stylua",
  diagnostics = "selene",
}

return lua
