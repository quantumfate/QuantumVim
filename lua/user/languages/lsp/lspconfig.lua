local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status_ok then
  return
end

local status_ok, lspconfig_init = pcall(require, "lspconfig")
if not status_ok then
  return
end
properties = pcall(require, "user.languages.utils.properties")

local handlers_status_ok, handlers = pcall(require, "user.languages.utils.handlers")
if not handlers_status_ok then
  return
end

local maintained_hooks_status_ok, maintained_hooks = pcall(require, "user.languages.maintained_hooks")
if not maintained_hooks_status_ok then
  return 
end

local nvim_cmp_status_ok, nvim_cmp = pcall(require, "user.languages.utils.nvim-cmp")
if not nvim_cmp_status_ok then
  return
end

mason_lspconfig.setup {
  ensure_installed = properties.servers,
  automatic_installation = true,
} -- automatically install specified servers

-- Global capabilities for all language server
local global_capabilities = vim.lsp.protocol.make_client_capabilities()
lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
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

local lspconfig = handlers.init_lsp_server_config(lspconfig_init, server_opts)
