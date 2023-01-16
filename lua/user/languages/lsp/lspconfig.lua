
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

local lsp_flags = {
  debounce_text_changes = 150, 
}
local server_opts = {
  flags = lsp_flags,
}

local server_flags = {}
for i, server in pairs(configured_language_server) do
  server_flags[server] = true
end


for language_config, language_values in pairs(configured_languages) do

  local lsp_status_ok, lspconfig_init = pcall(require, "lspconfig")
  if not lsp_status_ok then
    return
  end

  local current_lsp_server = language_values:get_lsp_server()
  local lspconfig_function = lspconfig_init[current_lsp_server].setup 

  if server_flags[current_lsp_server] then
    local init_status_ok, init_conf = pcall(handlers.init_lsp_server_config, language_config, language_values, lspconfig_function,server_opts)
    if not init_status_ok then
      vim.notify("An error occured when setting up lsp for the language server" .. current_lsp_server, "error")
      return
    else
      if not server_flags[current_lsp_server] and language_values:has_server_extension() then
        vim.notify("You configured two languages with server extensions and one overrides the other!", "warning")
      end
      server_flags[current_lsp_server] = false
    end  
  end



end


