
--[[
  Requiring the necessary modules
]]
local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status_ok then
  return
end

local lsp_status_ok, lspconfig_init = pcall(require, "lspconfig")
if not lsp_status_ok then
  return
end

local handlers_status_ok, handlers = pcall(require, "user.languages.utils.handlers")
if not handlers_status_ok then
  return
end


local nvim_cmp_status_ok, nvim_cmp = pcall(require, "user.languages.utils.nvim-cmp")
if not nvim_cmp_status_ok then
  return
end

local conf_languages_status_ok, conf_languages = pcall(require, "user.languages.config")
if not conf_languages_status_ok then
  return
end

local configured_languages = conf_languages:new()
local configured_language_server = configured_languages:get_unique_lsp_server_list()



mason_lspconfig.setup {
  ensure_installed = configured_language_server,
  automatic_installation = true,
} -- automatically install specified servers

-- Global capabilities for all language server
local global_capabilities = vim.lsp.protocol.make_client_capabilities()
lspconfig_init.util.default_config = vim.tbl_extend("force", lspconfig_init.util.default_config, {
  capabilities = global_capabilities,
})

local lsp_flags = {
  debounce_text_changes = 150, 
}
local server_opts = {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
  flags = lsp_flags,
}

local lspconfig = handlers.init_lsp_server_config(lspconfig_init, server_opts, configured_languages)
